"""
Entry point for the solc benchmarking infrastructure.

Usage:
    python run.py [--suite {synthetic,real-world,all}]
                  [--solc PATH]
                  [--repeats N]
                  [--output PATH]
                  [--baseline PATH]

All code uses Python stdlib only.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------

# run.py lives at test/benchmarks/run.py; repo root is 2 levels up.
_HERE = Path(__file__).resolve().parent          # test/benchmarks/
_REPO_ROOT = _HERE.parent.parent                 # <repo-root>/

# Allow importing sibling modules when run directly.
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from models import Sample  # noqa: E402
from runner import BenchmarkRunner, build_synthetic_cases, build_real_world_cases  # noqa: E402
from reporter import Reporter  # noqa: E402


# ---------------------------------------------------------------------------
# Task 8.1 — CLI argument parsing
# ---------------------------------------------------------------------------

def _default_solc_path() -> Path:
    """Return the default solc binary path.

    Resolves ``${SOLIDITY_BUILD_DIR}/solc/solc``, where ``SOLIDITY_BUILD_DIR``
    defaults to ``<repo-root>/build``.
    """
    build_dir = os.environ.get("SOLIDITY_BUILD_DIR", str(_REPO_ROOT / "build"))
    return Path(build_dir) / "solc" / "solc"


def _build_parser() -> argparse.ArgumentParser:
    """Construct and return the argument parser for run.py."""
    parser = argparse.ArgumentParser(
        prog="run.py",
        description="Run solc benchmarks and report results.",
    )
    parser.add_argument(
        "--suite",
        choices=["synthetic", "real-world", "all"],
        default="all",
        help="Which benchmark suite to run (default: all).",
    )
    parser.add_argument(
        "--solc",
        metavar="PATH",
        default=None,
        help=(
            "Path to the solc binary. "
            "Defaults to ${SOLIDITY_BUILD_DIR}/solc/solc "
            "(SOLIDITY_BUILD_DIR defaults to <repo-root>/build)."
        ),
    )
    parser.add_argument(
        "--repeats",
        metavar="N",
        type=int,
        default=3,
        help="Number of times each benchmark case is compiled (default: 3).",
    )
    parser.add_argument(
        "--output",
        metavar="PATH",
        default=None,
        help="Path for the JSON report file. If omitted, the report is written to stdout.",
    )
    parser.add_argument(
        "--baseline",
        metavar="PATH",
        default=None,
        help="Path to a baseline JSON report for regression comparison.",
    )
    return parser


def _validate_args(args: argparse.Namespace) -> Path:
    """Validate parsed arguments and return the resolved solc Path.

    Prints a descriptive error to stderr and calls sys.exit(1) if the solc
    binary is not executable.

    Args:
        args: Parsed namespace from argparse.

    Returns:
        Resolved Path to the solc binary.
    """
    solc_path = Path(args.solc) if args.solc is not None else _default_solc_path()

    if not os.access(solc_path, os.X_OK):
        print(
            f"error: solc binary '{solc_path}' is not executable or does not exist.\n"
            f"  Specify a valid path with --solc, or set the SOLIDITY_BUILD_DIR "
            f"environment variable.",
            file=sys.stderr,
        )
        sys.exit(1)

    return solc_path


# ---------------------------------------------------------------------------
# Task 8.2 — Wire runner and reporter together
# ---------------------------------------------------------------------------

def _get_solc_version(solc_path: Path) -> str:
    """Run ``solc --version`` and return the version string.

    Parses the first line containing "Version:" and returns the text after
    the colon.  Falls back to "unknown" on any error.

    Args:
        solc_path: Path to the solc binary.

    Returns:
        Version string, e.g. ``"0.8.30+commit.abc123"``.
    """
    try:
        result = subprocess.run(
            [str(solc_path), "--version"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        for line in result.stdout.splitlines():
            if "Version:" in line:
                # e.g. "Version: 0.8.30+commit.abc123"
                return line.split("Version:", 1)[1].strip()
    except Exception:
        pass
    return "unknown"


def _build_cases(suite: str) -> list:
    """Build the list of BenchmarkCase objects for the requested suite.

    Paths are resolved relative to the repo root (2 levels up from run.py).

    Args:
        suite: One of ``"synthetic"``, ``"real-world"``, or ``"all"``.

    Returns:
        List of BenchmarkCase objects.
    """
    output_dir = _REPO_ROOT / "test" / "benchmarks" / "generated"
    real_world_dir = _REPO_ROOT / "test" / "benchmarks" / "real-world"

    if suite == "synthetic":
        return build_synthetic_cases(output_dir=output_dir)
    elif suite == "real-world":
        return build_real_world_cases(real_world_dir=real_world_dir)
    else:  # "all"
        synthetic = build_synthetic_cases(output_dir=output_dir)
        real_world = build_real_world_cases(real_world_dir=real_world_dir)
        return synthetic + real_world


def main() -> None:
    """Parse arguments, run benchmarks, and report results.

    Always exits with status code 0 (Requirement 8.1).  Individual case
    failures are recorded in the report but do not abort the run.
    """
    parser = _build_parser()
    args = parser.parse_args()

    try:
        solc_path = _validate_args(args)

        # Resolve solc version for the report header.
        solc_version = _get_solc_version(solc_path)

        # Build the case list.
        cases = _build_cases(args.suite)

        # Run the suite.
        runner = BenchmarkRunner(solc_path=solc_path, repeats=args.repeats)
        samples: list[Sample] = runner.run_suite(cases)

        # Compute statistics and produce JSON report.
        stats = Reporter.compute_stats(samples)
        report = Reporter.to_json(stats, solc_version=solc_version)

        # Write JSON report to file or stdout.
        report_json = json.dumps(report, indent=2)
        if args.output:
            output_path = Path(args.output)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(report_json, encoding="utf-8")
        else:
            print(report_json)

        # Always print the human-readable console table to stdout.
        print(Reporter.format_table(stats))

        # If a baseline was provided, print the regression comparison.
        if args.baseline:
            baseline_path = Path(args.baseline)
            with open(baseline_path, encoding="utf-8") as fh:
                baseline = json.load(fh)
            print(Reporter.compare(baseline, report))

    except SystemExit:
        # Re-raise SystemExit from _validate_args (non-zero exit for bad solc).
        raise
    except Exception as exc:  # noqa: BLE001
        print(f"error: {exc}", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
