contract A layout at block.basefee { }
contract B layout at block.chainid { }
contract C layout at block.number { }
contract D layout at uint160(address(block.coinbase)) { }
contract E layout at block.prevrandao { }
contract F layout at uint(blockhash(0)) { }
contract G layout at msg.value { }
contract H layout at msg.sender { }
contract I layout at msg.data { }
contract J layout at tx.gasprice { }
contract K layout at uint160(tx.origin) { }
contract L layout at address(this).balance { }
contract M layout at uint(address(this).codehash) { }

// ====
// EVMVersion: >=paris
// ----
// TypeError 1139: (21-34): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (60-73): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (99-111): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (137-169): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (195-211): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (237-255): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (281-290): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (316-326): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (352-360): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (386-397): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (423-441): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (467-488): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (514-542): The base slot of the storage layout must be a compile-time constant expression.
