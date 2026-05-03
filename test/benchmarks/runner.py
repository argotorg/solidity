"""
Benchmark runner for the solc benchmarking infrastructure.

Orchestrates benchmark execution: builds case lists, invokes solc, collects
Sample objects, and returns them for downstream statistical reporting.

All code uses Python stdlib only.

Usage:
    from pathlib import Path
    from runner import BenchmarkRunner, build_synthetic_cases, build_real_world_cases

    runner = BenchmarkRunner(solc_path=Path("/usr/bin/solc"), repeats=3)
    cases = build_synthetic_cases(output_dir=Path("test/benchmarks/generated"))
    samples = runner.run_suite(cases)
"""

from __future__ import annotations

import logging
import os
import subprocess
import sys
import time
from datetime import datetime, timezone, UTC
from pathlib import Path
from typing import List

# Allow running from repo root or from test/benchmarks/ directly.
_HERE = Path(__file__).parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from models import BenchmarkCase, Sample  # noqa: E402
from contract_generator import StressCategory, generate  # noqa: E402

# ---------------------------------------------------------------------------
# Module-level logger (used as fallback; log() is the primary output function)
# ---------------------------------------------------------------------------
_logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Task 4.1 — RSS measurement and CI logging helpers
# ---------------------------------------------------------------------------

def _measure_peak_rss_mib() -> float:
    """Return the peak RSS of the most recently waited-for child process in MiB.

    Uses ``resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss``.

    Platform normalisation:
    - Linux:  ru_maxrss is in kilobytes  → divide by 1 024
    - macOS:  ru_maxrss is in bytes      → divide by 1 048 576
    - Other:  logs a warning and returns 0.0
    """
    try:
        import resource  # not available on Windows
    except ImportError:
        log("WARNING: resource module not available on this platform; RSS will be 0.0")
        return 0.0

    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    raw = usage.ru_maxrss

    if sys.platform == "darwin":
        # macOS returns bytes
        return raw / (1024 * 1024)
    elif sys.platform.startswith("linux"):
        # Linux returns kilobytes
        return raw / 1024
    else:
        log(f"WARNING: unsupported platform '{sys.platform}' for RSS measurement; returning 0.0")
        return 0.0


def log(msg: str) -> None:
    """Print *msg* to stdout, always flushing.

    When the ``CI`` environment variable is set to a non-empty value, each
    line is prefixed with an ISO 8601 UTC timestamp (e.g.
    ``2025-01-01T12:00:00.000000Z``).
    """
    if os.environ.get("CI"):
        timestamp = datetime.now(UTC).isoformat(timespec="seconds") + "Z"
        print(f"{timestamp} {msg}", flush=True)
    else:
        print(msg, flush=True)


# ---------------------------------------------------------------------------
# Task 4.2 — BenchmarkRunner.run_case()
# ---------------------------------------------------------------------------

class BenchmarkRunner:
    """Orchestrates benchmark execution against a solc binary.

    Args:
        solc_path: Path to the solc binary to benchmark.
        repeats:   Number of times each BenchmarkCase is compiled.
    """

    def __init__(self, solc_path: Path, repeats: int) -> None:
        self.solc_path = Path(solc_path)
        self.repeats = repeats

    # ------------------------------------------------------------------
    # Public interface
    # ------------------------------------------------------------------

    def run_case(self, case: BenchmarkCase) -> List[Sample]:
        """Invoke solc *repeats* times for *case* and return the samples.

        One warmup invocation is performed first (discarded) to prime the OS
        page cache and CPU branch predictor before measurements begin.

        Returns:
            A list of exactly ``self.repeats`` Sample objects.
        """
        samples: List[Sample] = []

        # Warmup run — result discarded
        if case.use_standard_json:
            cmd, stdin_data = self._build_standard_json_cmd(case)
        else:
            cmd, stdin_data = self._build_regular_cmd(case)
        subprocess.run(cmd, input=stdin_data, capture_output=True)

        for _ in range(self.repeats):
            if case.use_standard_json:
                cmd, stdin_data = self._build_standard_json_cmd(case)
            else:
                cmd, stdin_data = self._build_regular_cmd(case)

            t_start = time.perf_counter()
            result = subprocess.run(
                cmd,
                input=stdin_data,
                capture_output=True,
            )
            t_end = time.perf_counter()

            elapsed_s = t_end - t_start
            peak_rss_mib = _measure_peak_rss_mib()
            exit_code = result.returncode

            if exit_code != 0:
                log(
                    f"WARNING: solc exited with code {exit_code} for case '{case.case_id}'; "
                    "recording failure and continuing"
                )

            samples.append(
                Sample(
                    case_id=case.case_id,
                    elapsed_s=elapsed_s,
                    peak_rss_mib=peak_rss_mib,
                    exit_code=exit_code,
                )
            )

        return samples

    # ------------------------------------------------------------------
    # Task 4.3 — run_suite()
    # ------------------------------------------------------------------

    def run_suite(self, cases: List[BenchmarkCase]) -> List[Sample]:
        """Run all *cases* and return the accumulated list of samples.

        Args:
            cases: Ordered list of BenchmarkCase objects to execute.

        Returns:
            All Sample objects collected across every case.
        """
        all_samples: List[Sample] = []
        for case in cases:
            log(f"Running case: {case.case_id}")
            samples = self.run_case(case)
            all_samples.extend(samples)
        return all_samples

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _build_regular_cmd(self, case: BenchmarkCase):
        """Build the command list for a non-standard-json case.

        Returns:
            (cmd: list[str], stdin_data: None)
        """
        cmd = [str(self.solc_path), str(case.source_path), "--bin"]

        # --optimize is not compatible with ethdebug (experimental); omit it
        # when debug info is on.
        if case.debug_info_mode == "off":
            cmd.append("--optimize")

        if case.pipeline == "ir":
            cmd.append("--via-ir")

        if case.debug_info_mode == "on":
            cmd.extend(["--debug-info", "ethdebug", "--experimental"])

        return cmd, None

    def _build_standard_json_cmd(self, case: BenchmarkCase):
        """Build the command list for a standard-json case.

        The source file content is read and passed via stdin.

        Returns:
            (cmd: list[str], stdin_data: bytes)
        """
        cmd = [str(self.solc_path), "--standard-json"]

        if case.pipeline == "ir":
            cmd.append("--via-ir")

        if case.debug_info_mode == "on":
            cmd.extend(["--debug-info", "ethdebug", "--experimental"])

        stdin_data = case.source_path.read_bytes()
        return cmd, stdin_data


# ---------------------------------------------------------------------------
# Task 4.3 — Case-list builders
# ---------------------------------------------------------------------------

def build_synthetic_cases(output_dir: Path) -> List[BenchmarkCase]:
    """Generate synthetic .sol files and return the full list of BenchmarkCases.

    Produces all combinations of:
    - 5 StressCategory values
    - 2 pipelines: "legacy", "ir"
    - 2 debug modes: "off", "on"

    Total: 5 × 2 × 2 = 20 cases.

    Args:
        output_dir: Directory where generated .sol files are written.

    Returns:
        List of 20 BenchmarkCase objects.
    """
    output_dir = Path(output_dir)
    cases: List[BenchmarkCase] = []

    pipelines = ["legacy", "ir"]
    debug_modes = ["off", "on"]

    for category in StressCategory:
        source_path = generate(category, output_dir=output_dir)
        for pipeline in pipelines:
            for debug_mode in debug_modes:
                case_id = f"{category.value}-{pipeline}-{debug_mode}"
                cases.append(
                    BenchmarkCase(
                        case_id=case_id,
                        source_path=source_path,
                        pipeline=pipeline,
                        debug_info_mode=debug_mode,
                        use_standard_json=False,
                    )
                )

    return cases


def build_real_world_cases(real_world_dir: Path) -> List[BenchmarkCase]:
    """Scan *real_world_dir* for *.json files and return BenchmarkCases.

    Each JSON file becomes one BenchmarkCase with ``use_standard_json=True``.
    If the directory does not exist or contains no JSON files, a warning is
    logged and an empty list is returned.

    Args:
        real_world_dir: Directory containing standard-JSON input files.

    Returns:
        List of BenchmarkCase objects (may be empty).
    """
    real_world_dir = Path(real_world_dir)

    if not real_world_dir.exists():
        log(f"WARNING: real-world directory '{real_world_dir}' does not exist; skipping")
        return []

    json_files = sorted(real_world_dir.glob("*.json"))

    if not json_files:
        log(f"WARNING: no *.json files found in '{real_world_dir}'; skipping real-world suite")
        return []

    cases: List[BenchmarkCase] = []
    pipelines = ["legacy", "ir"]
    debug_modes = ["off", "on"]

    for json_file in json_files:
        stem = json_file.stem  # e.g. "openzeppelin-5.0.2"
        for pipeline in pipelines:
            for debug_mode in debug_modes:
                case_id = f"{stem}-{pipeline}-{debug_mode}"
                cases.append(
                    BenchmarkCase(
                        case_id=case_id,
                        source_path=json_file,
                        pipeline=pipeline,
                        debug_info_mode=debug_mode,
                        use_standard_json=True,
                    )
                )

    return cases
