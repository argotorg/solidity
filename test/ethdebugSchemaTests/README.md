# ETHDebug schema tests

These tests validate Solidity's ETHDebug output against a pinned checkout of the upstream `ethdebug/format` JSON Schemas.

The schema checkout is a git submodule at `test/ethdebugSchemaTests/ethdebug-format`.
Initialize it with:

```bash
git submodule update --init test/ethdebugSchemaTests/ethdebug-format
```

Run the tests with:

```bash
test/ethdebugSchemaTests.py --solc-binary-path build/solc/solc
```

The runner discovers every test module in this directory and passes the compiler path to the test cases.
To run only some tests, use the `-k` option to specify a pattern, as with [`python -m unittest -k`](https://docs.python.org/3/library/unittest.html#cmdoption-unittest-k):

```bash
test/ethdebugSchemaTests.py --solc-binary-path build/solc/solc -k test_deployed_program_schema
```

The suite uses `input_template.json` to compile the `.sol` files under `sources/` together, and each isoltest fixture under `test/libsolidity/ethdebugTests/resources/` separately.
Both directories are searched recursively.
Every supported input runs through the full conformity suite, using Standard JSON and compiling once for all tests of that input.
Multi-source fixtures (`==== Source: ... ====`) are skipped for now.
Support is deferred until source splitting can be shared with `scripts/splitSources.py`.
Settings and expectations are excluded from single-source inputs.

The suite only checks properties that hold for the output of any input.
The expected output for specific inputs is pinned down by the isoltest cases under `test/libsolidity/ethdebugTests/`.
Resource fixtures use `type_discovery_` and `pointer_discovery_` prefixes for tests of which types and layouts are included.
These mostly check identifier lists or counts, with comments explaining intentional omissions.
The `type_structure_` and `pointer_structure_` fixtures check the contents of type documents and pointer templates.

`known_schema_fields.json` records the property names declared by the type and pointer schemas, including optional fields.
The inventory is checked during class setup, before compiling any input.
Schema validation alone cannot detect that the producer or a test helper has overlooked a newly added optional field.
When the schemas change, review the producer and the helpers before updating this inventory.

After that review, regenerate it with:

```bash
python3 test/ethdebugSchemaTests/generate_schema_fields.py
```

The submodule is pinned to the `0.1.0-draft.2` release of ethdebug/format, the version the compiler targets.
To update the schema version, bump the submodule commit, update the version and the links in `docs/ethdebug.rst` and rerun this suite.
