# PR: keccak256() e uint() in contesto comptime per layout

## 1. Branch e base

Per una PR pulita verso `develop` del repo upstream (argotorg/solidity), crea un branch **nuovo** a partire da `develop`:

```powershell
cd "u:\personale\GitHub PRs Projects\solidity"

# Salva le modifiche
git stash push -m "keccak256-comptime" -- Changelog.md libsolidity/analysis/ConstantEvaluator.cpp libsolidity/analysis/ConstantEvaluator.h "test/libsolidity/syntaxTests/storageLayoutSpecifier/literal_cast.sol" "test/libsolidity/syntaxTests/storageLayoutSpecifier/layout_keccak256_string_literal.sol"

# Aggiorna develop dal tuo fork (o da upstream)
git fetch origin develop

# Nuovo branch da develop
git checkout -b feature/keccak256-comptime-layout origin/develop

# Ripristina le modifiche
git stash pop
```

Se preferisci lavorare sul branch attuale (es. `fix/isoltest-interactive-update-crash`) e aprire la PR da lì, salta lo stash/fetch/checkout e crea solo il branch:

```powershell
git checkout -b feature/keccak256-comptime-layout
```

---

## 2. Commit

```powershell
git add Changelog.md libsolidity/analysis/ConstantEvaluator.cpp libsolidity/analysis/ConstantEvaluator.h "test/libsolidity/syntaxTests/storageLayoutSpecifier/literal_cast.sol" "test/libsolidity/syntaxTests/storageLayoutSpecifier/layout_keccak256_string_literal.sol"

git status
# Verifica che ci siano solo questi 5 file

git commit -m "Add keccak256() and uint() evaluation in comptime for layout base expressions"
```

*(Non inserire il numero di issue nel messaggio di commit, come da ReviewChecklist.)*

---

## 3. Push sul tuo fork

```powershell
git push origin feature/keccak256-comptime-layout
```

Se `origin` non punta al tuo fork (JPier34/solidity), usa il remote corretto, ad es.:

```powershell
git remote -v
# Se serve: git remote add origin https://github.com/JPier34/solidity.git

git push origin feature/keccak256-comptime-layout
```

---

## 4. Titolo PR (senza numero di issue)

**Suggerimento:**

```
Allow keccak256() and uint() in compile-time context for layout base expressions
```

---

## 5. Descrizione PR

Copia e incolla nel corpo della PR (adatta se necessario):

```markdown
## Summary

Implements evaluation of `keccak256()` in compile-time context and explicit `uint()` conversion in compile-time context (Stage 1 of built-in value type conversions). This allows using `keccak256()` in storage layout base expressions, e.g.:

```solidity
contract C layout at uint(keccak256("my.contract.id")) {}
```

Fixes #16421. Implements Stage 1 of #16420.

## Motivation

Layout base expressions in common use are either erc7201 (handled in PR #15968) or plain hashing with `keccak256()`. This change supports the latter. `keccak256()` returns `bytes32` while layout base must be an integer; we therefore also evaluate explicit `uint()` conversions in comptime so that `uint(keccak256("..."))` is valid.

## Changes

- **ConstantEvaluator**: Evaluate `uint(...)` type conversion in comptime when target type is `uint256` (overflow/underflow → compile error). Evaluate builtin `keccak256(...)` in comptime when the argument is a string or hex literal; result is represented as `bytes32` and can be used inside `uint(...)`.
- **Tests**: `literal_cast.sol` now expects success for `uint(42)`; new test `layout_keccak256_string_literal.sol` for `layout at uint(keccak256("my.contract.id"))`.
- **Changelog**: Entry under 0.8.34 (unreleased) Language Features.

## Backwards compatibility

Fully backwards-compatible; no change to runtime behaviour.
```

---

## 6. Dopo l’apertura della PR

- Controlla che la base della PR sia `develop` (o il branch richiesto dal repo upstream).
- Se la CI fallisce sui test, esegui in locale i test pertinenti (es. syntaxTests per storage layout) e correggi prima di pushare di nuovo.
```

Eliminando il file di istruzioni dal commit (è solo per te).
<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
Read