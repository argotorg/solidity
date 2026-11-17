{
  "contracts": {
    "test/cmdlineTests/ast_import_src_field_two_fields/input.sol:C": {}
  },
  "sourceList": [
    "test/cmdlineTests/ast_import_src_field_two_fields/input.sol"
  ],
  "sources": {
    "test/cmdlineTests/ast_import_src_field_two_fields/input.sol": {
      "AST": {
        "absolutePath": "test/cmdlineTests/ast_import_src_field_two_fields/input.sol",
        "exportedSymbols": {
          "C": [
            10
          ]
        },
        "id": 11,
        "license": "GPL-3.0",
        "nodeType": "SourceUnit",
        "nodes": [
          {
            "id": 1,
            "literals": [
              "solidity",
              ">=",
              "0.0"
            ],
            "nodeType": "PragmaDirective",
            "src": "36:22:0"
          },
          {
            "abstract": false,
            "baseContracts": [],
            "canonicalName": "C",
            "contractDependencies": [],
            "contractKind": "contract",
            "fullyImplemented": true,
            "id": 10,
            "linearizedBaseContracts": [
              10
            ],
            "name": "C",
            "nameLocation": "68:1:0",
            "nodeType": "ContractDefinition",
            "nodes": [
              {
                "body": {
                  "id": 8,
                  "nodeType": "Block",
                  "src": "112:13:0",
                  "statements": [
                    {
                      "expression": {
                        "hexValue": "31",
                        "id": 6,
                        "isConstant": false,
                        "isLValue": false,
                        "isPure": true,
                        "kind": "number",
                        "lValueRequested": false,
                        "nodeType": "Literal",
                        "src": "121:1:0",
                        "typeDescriptions": {
                          "typeIdentifier": "t_rational_1_by_1",
                          "typeString": "int_const 1"
                        },
                        "value": "1"
                      },
                      "functionReturnParameters": 5,
                      "id": 7,
                      "nodeType": "Return",
                      "src": "114:8:0"
                    }
                  ]
                },
                "functionSelector": "26121ff0",
                "id": 9,
                "implemented": true,
                "kind": "function",
                "modifiers": [],
                "name": "f",
                "nameLocation": "81:1:0",
                "nodeType": "FunctionDefinition",
                "parameters": {
                  "id": 2,
                  "nodeType": "ParameterList",
                  "parameters": [],
                  "src": "82:2:0"
                },
                "returnParameters": {
                  "id": 5,
                  "nodeType": "ParameterList",
                  "parameters": [
                    {
                      "constant": false,
                      "id": 4,
                      "mutability": "mutable",
                      "name": "",
                      "nameLocation": "-1:-1:-1",
                      "nodeType": "VariableDeclaration",
                      "scope": 9,
                      "src": "106:4:0",
                      "stateVariable": false,
                      "storageLocation": "default",
                      "typeDescriptions": {
                        "typeIdentifier": "t_uint256",
                        "typeString": "uint256"
                      },
                      "typeName": {
                        "id": 3,
                        "name": "uint",
                        "nodeType": "ElementaryTypeName",
                        "src": "106:4:0",
                        "typeDescriptions": {
                          "typeIdentifier": "t_uint256",
                          "typeString": "uint256"
                        }
                      },
                      "visibility": "internal"
                    }
                  ],
                  "src": "105:6:0"
                },
                "scope": 10,
                "src": "72:53:0",
                "stateMutability": "pure",
                "virtual": false,
                "visibility": "public"
              }
            ],
            "scope": 11,
            "src": "59:68:0",
            "usedErrors": [],
            "usedEvents": []
          }
        ],
        "src": "1:2"
      },
      "id": 0
    }
  },
  "version": "0.8.39-develop.2026.11.3+commit.765afa06.mod.Linux.g++"
}
