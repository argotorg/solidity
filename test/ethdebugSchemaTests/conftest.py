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
def ethdebug_schema_dir():
    schema_dir = Path(__file__).parent / "ethdebug-format" / "schemas"
    assert schema_dir.is_dir(), (
        "ethdebug/format schemas are missing. "
        "Run `git submodule update --init test/ethdebugSchemaTests/ethdebug-format`."
    )
    return schema_dir


@pytest.fixture(scope="module")
def ethdebug_schema_repository(ethdebug_schema_dir):
    registry = referencing.Registry()
    for path in ethdebug_schema_dir.rglob("*.yaml"):
        with open(path, "r", encoding="utf8") as f:
            schema = yaml.safe_load(f)
            if "$id" in schema:
                resource = referencing.Resource.from_contents(schema, DRAFT202012)
                registry = resource @ registry
            else:
                raise ValueError(f"Schema did not define an $id: {path}")
    return registry
