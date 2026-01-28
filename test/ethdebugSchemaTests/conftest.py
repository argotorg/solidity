import shutil
import subprocess
from pathlib import Path

import pytest
import referencing
import yaml
from referencing.jsonschema import DRAFT202012


def pytest_addoption(parser):
    parser.addoption("--solc-binary-path", type=Path, required=True, help="Path to the solidity compiler binary.")


@pytest.fixture
def solc_path(request):
    solc_path = request.config.getoption("--solc-binary-path")
    assert solc_path.is_file()
    assert solc_path.exists()
    return solc_path


@pytest.fixture(scope="module")
def ethdebug_clone_dir(tmpdir_factory):
    temporary_dir = Path(tmpdir_factory.mktemp("data"))
    yield temporary_dir
    shutil.rmtree(temporary_dir)


@pytest.fixture(scope="module")
def ethdebug_schema_repository(ethdebug_clone_dir):
    process = subprocess.run(
        ["git", "clone", "https://github.com/ethdebug/format.git", ethdebug_clone_dir],
        encoding="utf8",
        capture_output=True,
        check=True
    )
    assert process.returncode == 0

    registry = referencing.Registry()
    for path in (ethdebug_clone_dir / "schemas").rglob("*.yaml"):
        with open(path, "r", encoding="utf8") as f:
            schema = yaml.safe_load(f)
            if "$id" in schema:
                resource = referencing.Resource.from_contents(schema, DRAFT202012)
                registry = resource @ registry
            else:
                raise ValueError(f"Schema did not define an $id: {path}")
    return registry
