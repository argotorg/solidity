.. index:: ! output selection, compilation, compiler output

*******************
Output Selection Examples
*******************

.. _output-selection-examples:

This document provides examples of using the ``outputSelection`` field in the Standard JSON interface to optimize your compilation workflow.

Basic Output Selection
=====================

Here's a simple example to get started with output selection:

.. code-block:: javascript

    {
      "language": "Solidity",
      "sources": {
        "contract.sol": {
          "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.7.0 <0.9.0;\n\ncontract MyContract {\n    uint256 private value;\n    \n    function setValue(uint256 _value) public {\n        value = _value;\n    }\n    \n    function getValue() public view returns (uint256) {\n        return value;\n    }\n}"
        }
      },
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "abi",
              "evm.bytecode.object"
            ]
          }
        }
      }
    }

This example requests only the ABI and the bytecode object for all contracts in all files.

Development vs Production
========================

For development environments, you may want more detailed output, while production builds might need a minimal set of outputs.

Development Environment:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "abi",
              "metadata",
              "evm.bytecode",
              "evm.deployedBytecode",
              "evm.methodIdentifiers",
              "evm.gasEstimates",
              "evm.assembly"
            ],
            "": [
              "ast"
            ]
          }
        }
      }
    }

Production Environment:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "abi",
              "evm.bytecode.object",
              "evm.deployedBytecode.object"
            ]
          }
        }
      }
    }

Targeted Contract Compilation
============================

When working with many contracts, you can target specific contracts to speed up compilation:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "MainContract.sol": {
            "MainContract": [
              "abi",
              "evm.bytecode.object",
              "evm.deployedBytecode.object"
            ]
          },
          "*": {
            "": [
              "ast"
            ]
          }
        }
      }
    }

This example generates outputs only for ``MainContract`` in ``MainContract.sol`` while still generating AST for all source files.

Experimental Outputs
===================

To request experimental outputs along with standard ones:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "*",           // All standard outputs
              "ir",          // Explicitly request experimental IR output
              "irOptimized"  // Explicitly request optimized IR
            ]
          }
        }
      }
    }

Optimizing for Framework Usage
============================

For frameworks that need specific outputs for different operations:

Contract Verification:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "metadata"
            ]
          }
        }
      }
    }

Contract Interaction:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "abi"
            ]
          }
        }
      }
    }

Contract Deployment:

.. code-block:: javascript

    {
      "settings": {
        "outputSelection": {
          "*": {
            "*": [
              "abi",
              "evm.bytecode.object",
              "evm.bytecode.linkReferences"
            ]
          }
        }
      }
    }

Complete Example with Multiple Files
==================================

This example shows a more complex scenario with multiple files and specific output needs:

.. code-block:: javascript

    {
      "language": "Solidity",
      "sources": {
        "Token.sol": {
          "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract Token {\n    // token implementation\n}"
        },
        "Marketplace.sol": {
          "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport './Token.sol';\n\ncontract Marketplace {\n    // marketplace implementation using Token\n}"
        },
        "Utils.sol": {
          "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nlibrary Utils {\n    // utility functions\n}"
        }
      },
      "settings": {
        "outputSelection": {
          "Marketplace.sol": {
            "Marketplace": [
              "abi",
              "evm.bytecode.object",
              "evm.deployedBytecode.object",
              "evm.gasEstimates"
            ]
          },
          "Token.sol": {
            "Token": [
              "abi"
            ]
          },
          "Utils.sol": {
            "Utils": [
              "abi",
              "evm.bytecode.object"
            ]
          },
          "*": {
            "": [
              "ast"
            ]
          }
        }
      }
    }

This selection would:
1. Generate full bytecode and gas estimates for the Marketplace contract
2. Generate only ABI for the Token contract (since it's imported but we might only need its interface)
3. Generate ABI and bytecode for the Utils library
4. Generate AST for all source files 
