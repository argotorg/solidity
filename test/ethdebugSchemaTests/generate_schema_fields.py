#!/usr/bin/env python3

"""
Regenerate known_schema_fields.json from the pinned ethdebug/format schemas.
"""

import json
from pathlib import Path

# pragma pylint: disable=import-error
import schema_helpers
# pragma pylint: enable=import-error


if __name__ == "__main__":
    repository = schema_helpers.ethdebug_schema_repository(schema_helpers.ethdebug_schema_dir())
    fields = schema_helpers.type_and_pointer_schema_fields(repository)
    with open(Path(__file__).with_name("known_schema_fields.json"), "w", encoding="utf8") as file:
        json.dump(fields, file, indent=4, sort_keys=True)
        file.write("\n")
