"""
Shared data model dataclasses for the solc benchmarking infrastructure.

These types flow through the pipeline:
  BenchmarkCase  ->  runner.py  ->  Sample  ->  reporter.py  ->  CaseStats
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class BenchmarkCase:
    """A single compilation task to be benchmarked.

    Attributes:
        case_id:          Unique identifier, e.g. "deep-nesting-legacy-off".
        source_path:      Path to the .sol source or standard-JSON input file.
        pipeline:         Compiler code-generation path: "legacy" or "ir".
        debug_info_mode:  Whether ethdebug info is emitted: "on" or "off".
        use_standard_json: When True the input is passed via --standard-json.
    """

    case_id: str
    source_path: Path
    pipeline: str           # "legacy" | "ir"
    debug_info_mode: str    # "on" | "off"
    use_standard_json: bool = False


@dataclass
class Sample:
    """One wall-clock time and peak-RSS measurement for a single BenchmarkCase run.

    Attributes:
        case_id:       Identifies which BenchmarkCase produced this sample.
        elapsed_s:     Wall-clock elapsed time in seconds (≥ 0).
        peak_rss_mib:  Peak resident-set size in mebibytes (> 0 on success).
        exit_code:     Exit code of the solc invocation (0 = success).
    """

    case_id: str
    elapsed_s: float
    peak_rss_mib: float
    exit_code: int


@dataclass
class CaseStats:
    """Aggregated statistics for all Samples belonging to one BenchmarkCase.

    Attributes:
        case_id:           Identifies the BenchmarkCase.
        pipeline:          "legacy" or "ir".
        debug_info_mode:   "on" or "off".
        repeat_count:      Total number of samples collected (including failures).
        time_median_s:     Median of elapsed_s across all samples.
        time_mean_s:       Arithmetic mean of elapsed_s across all samples.
        time_variance_s2:  Sample variance of elapsed_s (ddof=1; 0.0 for single sample).
        rss_median_mib:    Median of peak_rss_mib across all samples.
        rss_mean_mib:      Arithmetic mean of peak_rss_mib across all samples.
        rss_variance_mib2: Sample variance of peak_rss_mib (ddof=1; 0.0 for single sample).
        failed_count:      Number of samples whose exit_code was non-zero.
    """

    case_id: str
    pipeline: str
    debug_info_mode: str
    repeat_count: int
    time_median_s: float
    time_mean_s: float
    time_variance_s2: float
    rss_median_mib: float
    rss_mean_mib: float
    rss_variance_mib2: float
    failed_count: int
