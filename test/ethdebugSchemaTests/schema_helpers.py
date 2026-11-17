from pathlib import Path

import referencing
import yaml
from referencing.jsonschema import DRAFT202012


def ethdebug_schema_dir():
    schema_dir = Path(__file__).parent / "ethdebug-format" / "schemas"
    assert schema_dir.is_dir(), (
        "ethdebug/format schemas are missing. "
        "Run `git submodule update --init test/ethdebugSchemaTests/ethdebug-format`."
    )
    return schema_dir


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


def schema_fields(schema, path=""):
    """
    Property names at each schema path, including optional and pattern properties.
    """
    fields = {}
    if isinstance(schema, dict):
        for key, value in schema.items():
            if key in ("properties", "patternProperties"):
                fields[f"{path}/{key}"] = sorted(value)
            if key not in ("examples", "default", "const", "enum"):
                fields.update(schema_fields(value, f"{path}/{key}"))
    elif isinstance(schema, list):
        for index, value in enumerate(schema):
            fields.update(schema_fields(value, f"{path}/{index}"))
    return fields


def type_and_pointer_schema_fields(repository):
    return {
        name.removeprefix("schema:ethdebug/format/"): schema_fields(repository[name].contents)
        for name in repository
        if name.removeprefix("schema:ethdebug/format/").split("/")[0] in ("type", "pointer")
    }
