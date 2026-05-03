# Real-World Benchmark Inputs

This directory holds **standard-JSON input files** used by the `real-world` benchmark suite.
Each file is a complete `--standard-json` payload that can be fed directly to `solc`, covering
a realistic, large-scale Solidity codebase.

---

## Purpose

Synthetic contracts exercise specific compiler subsystems in isolation, but they cannot capture
the full complexity of real-world projects. This suite compiles well-known open-source projects
to measure how large pull requests (e.g. ethdebug support) affect compilation time and memory
usage against realistic inputs.

---

## Provenance

The table below records the origin of every standard-JSON file that belongs in this directory.
Keep this table up to date whenever a new file is added or an existing one is updated.

| Project | Version | Source URL | Extracted From |
|---------|---------|------------|----------------|
| *(no files yet — see instructions below)* | | | |

---

## Adding a New Real-World Benchmark

To add a new project to the suite:

1. **Obtain the project source.** Clone or download the release tarball of the project at the
   desired version, e.g.:
   ```
   git clone --depth 1 --branch v5.0.2 https://github.com/OpenZeppelin/openzeppelin-contracts.git
   ```

2. **Compile the project once with Hardhat or Foundry** to let the build tool resolve imports
   and produce a compilation artifact. For Hardhat:
   ```
   npm install
   npx hardhat compile --config hardhat.config.js
   ```
   For Foundry:
   ```
   forge build
   ```

3. **Extract the standard-JSON input.** The easiest method is to run `solc` with
   `--standard-json` and capture the input that the build tool would pass. With Hardhat you can
   inspect `artifacts/build-info/*.json` — each file contains an `input` key that is the
   standard-JSON payload. Extract it:
   ```python
   import json, pathlib
   build_info = json.loads(pathlib.Path("artifacts/build-info/<hash>.json").read_text())
   pathlib.Path("openzeppelin-5.0.2.json").write_text(json.dumps(build_info["input"], indent=2))
   ```
   With Foundry, the equivalent lives in `out/<ContractName>.sol/<ContractName>.json` under the
   `metadata.settings` key, but the simplest approach is to run:
   ```
   forge build --extra-output-files ir
   ```
   and reconstruct the standard-JSON manually, or use a helper script.

4. **Name the file** using the convention `<project>-<version>.json`, e.g.
   `openzeppelin-5.0.2.json`.

5. **Place the file in this directory** (`test/benchmarks/real-world/`).

6. **Update the Provenance table** above with the project name, version, source URL, and where
   the standard-JSON was extracted from (e.g. "Hardhat build-info artifact").

7. **Verify** the file works with the benchmark runner:
   ```
   python test/benchmarks/run.py --suite real-world --solc <path-to-solc>
   ```

---

## Important: JSON Files Are Not Committed

`.json` files in this directory are **not committed to the repository**. They can be large
(several megabytes) and are downloaded or generated separately before running the real-world
suite. Only this `README.md` is tracked by git.

If the benchmark runner cannot find a `.json` file it expects, it will emit a warning and skip
that case rather than aborting the run.

---

## Running the Real-World Suite

To run only the real-world benchmarks:

```
python test/benchmarks/run.py --suite real-world --solc <path-to-solc>
```

Additional options:

```
# Specify number of measurement repeats (default: 3)
python test/benchmarks/run.py --suite real-world --solc <path> --repeats 5

# Save the JSON report to a file
python test/benchmarks/run.py --suite real-world --solc <path> --output report.json

# Compare against a previous run
python test/benchmarks/run.py --suite real-world --solc <path> --baseline previous-report.json
```
