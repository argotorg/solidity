const tape = require('tape');
const fs = require('fs');
const solc = require('../index.js');

tape('ASM Json output consistency', function (t) {
    t.test('Nested structure', function(st) {
        const testdir = 'test/';
        const output = JSON.parse(solc.compile(JSON.stringify({
            language: 'Solidity',
            settings: {
                viaIR: true,
                outputSelection: {
                    '*': {
                        '*': ['evm.legacyAssembly']
                    }
                }
            },
            sources: {
                C: {
                    content: fs.readFileSync(testdir + 'code_access_runtime.sol', 'utf8')
                }
            }
        })));
        st.ok(output);

        function containsAssemblyItem(assemblyJSON, assemblyItem) {
            if (Array.isArray(assemblyJSON))
                return assemblyJSON.some(item => containsAssemblyItem(item, assemblyItem));
            else if (typeof assemblyJSON === 'object' && assemblyJSON !== null) {
                if (assemblyJSON.name === assemblyItem.name && assemblyJSON.value === assemblyItem.value)
                    return true;
                return Object.values(assemblyJSON).some(value => containsAssemblyItem(value, assemblyItem));
            }
            return false;
        }

        // regression test that there is indeed a negative subassembly index in there
        // and it is based on a 64 bit uint
        const targetObject = {
            "name": "PUSH #[$]",
            "value": "000000000000000000000000000000000000000000000000ffffffffffffffff"
        };
        st.equal(containsAssemblyItem(output["contracts"]["C"]["C"]["evm"]["legacyAssembly"], targetObject), true)
    });
});
