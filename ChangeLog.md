## [3.5.0] - 2021-06-28

### Added

- Initial release of a [NPM Package](https://www.npmjs.com/package/bcc-addresses)
  which uses the GHCJS build.

### Changed

- The supported compiler version is now GHC 8.10.4.

- Updated `validateScriptTemplate` and `validateScriptOfTemplate`
  functions for multi-signature wallets.


## [3.4.0] - 2021-04-30

### Added

- Added `Bcc.Address.Style.Sophie.eitherInspectAddress` function
  with stronger result and error types.

- Added `Bcc.Address.Style.Shared` module which defines a shared
  wallet style enabling multisig.

### Changed

- The constructors of `Bcc.Address.Style.Sophie.ErrInspectAddress`
  have changed.
  Any code which pattern matches on this type will need minor changes.

- A number of Bech32 prefixes were changed to account for CIP changes.
  The whole family of `*_shared_*` prefixes were introduced to accommodate
  newly added shared wallet style. In specific, there in no longer `script_vkh`
  but `addr_shared_vkh` and `stake_shared_vkh` to denote spending and stake
  verification key hashes, respectively.

- `KeyHash` now needs `KeyRole` values to be specified, except binary
  payload. It was needed change to enable differentiating between
  spending and stake key hashes.

### Removed

- Multisig related functions were deleted from `Bcc.Address.Style.Sophie` as they
  found a new place in `Bcc.Address.Style.Shared`.


## [3.3.0] - 2021-04-09

### Added

- The library now builds with ghcjs and passes tests running on nodejs.

- The `bcc-address inspect` command now includes bech32
  encodings. In the output, the JSON attribute will have a `_bech32`
  suffix. For example, `stake_key_hash_bech32`.

### Changed

- The `Index` type no longer has an `Enum` instance. Use
  `indexFromWord32` and `indexToWord32` instead.

- (Breaking change) The `Bcc.Address.bech32` function will now use
  the `addr_test` prefix instead of `addr`, if the given address is
  not a mainnet address.

### Removed

N/A


## [3.2.0] - 2020-01-22

### Added

- Added definition for 'Cosigner'.

- Added definition for 'ScriptTemplate', `ToJSON` and `FromJSON` instances added.

- Added validation of 'ScriptTemplate'.

- Added command-line for 'bcc-address script validate'

- Introduced 'foldScript' function.

### Changed

- Fixed `bcc-address --version` reporting.

- Added Ord instance for 'ScriptHash'.

- Extended script to account for ActiveFromSlot and ActiveUntilSlot, ie., introducing timelocks. `ToJSON` and `FromJSON` instances were updated. Also command-line supports
  timelocks now via 'active_from' and 'active_until`.

- Introduced Required and Recommended validation and adjusted the current one.

- Fixed bcc-address address bootstrap example in command-line help.

- Add missing crc32 integrity check when decoding Cole/Icarus addresses.

- Parametrized 'Script', and use it with 'ScriptHash' and 'Cosigner'.

- Better error reporting upon validation.

- Correcting bcc-address hash example in command-line help.

- Adding more examples to README.md

### Removed

N/A

## [3.1.0] - 2020-11-13

### Added

N/A

### Changed

- 'keyHashFromText' now works seamlessly with key, extended keys or key hashes. In case a key or extended key is given, the relevant part will be hashed on the fly. Said differently, it means that
  the command-line and the JSON instance for 'Script' works transparently with keys or key hashes.

- Fixed a bug with the `key hash` command which failed when provided with extended keys.

- The 'FromJSON' instance for 'Script' now runs the validation within the JSON parser, such that when the parser succeeds the resulting 'Script' is indeed valid.

- The 'FromJSON' instance for 'Script' is now much better at showing errors.

### Removed

N/A

## [3.0.0] - 2020-11-12

### Added

- Support for (multisig) scripts and script addresses in modules:
  - `Bcc.Address.Script`
  - `Bcc.Address.Script.Parser`

- Support for constructing scripts and script addresses via the command-line.

- Support for constructing rewards addresses via the library and command-line.

- New command for computing key and script hashes that are required in the construction of larger objects (e.g. addresses).

- Support for cabal build.

### Changed

- The command-line API no longer support multi-encoding (base16, bech32 and base58) but instead, enforces bech32 for keys and addresses, with specific human readable prefixes. It is still possible to easily go from base16-encoded data to bech32 by piping data through the [`bech32`](https://github.com/The-Blockchain-Company/bech32/) command-line.

- It is no longer possible to derive child keys to and from any path. Are only allowed:
   - root -> account
   - root -> address
   - account -> address
  This is reflected in the bech32 prefixes of the inputs and outputs.

- Allow constructing delegation addresses from a script. This works transparently from previous version of the command-line, but the command now also accepts script hashes as possible valid inputs.

### Removed

- No more `--legacy` option on the `key child` command. Which derivation scheme to use is now inferred from the bech32 prefixe used and the derivation path.

- `Bcc.Address.Errors` module. Errors data-types have been moved to their respective module `Bcc.Address.Styles.{Cole,Icarus,Sophie}`

- Anything related to Quibitous in both the library and the command-line.

## [2.1.0] - 2020-09-29

### Added

- Added constructors to derive keys on the multisig role.
- Made the parser for `--network-tag` more user friendly by now accepting pre-defined keywords such as "mainnet" or "testnet".

### Changed

- Renamed `AccountingStyle` into `Role` to better capture the semantic of the 4th level in derivation paths.
- Made script hashes 28-byte long again, after this was fixed upstream in the Bcc ledger.

### Removed

N/A


## [2.0.0] - 2020-09-10

### Added

- Command-line interface `bcc-address` for managing recovery-phrases, keys and addresses.
- Support for Sophie-specific address types.
- Support for Quibitous-specific address types.

### Changed

- Repository structure re-organized in two packages: core & command-line.

### Removed

N/A


## [1.0.0] - 2020-04-21

### Added

- 'Bcc.Mnemonic' module for mnemonic generation and manipulation.
- 'Bcc.Address' module for address creation, encoding and decoding.
- 'Bcc.Address.Derivation' module for primitives and abstractions regarding hierarchical derivation of credentials.
- 'Bcc.Address.Style.Cole' module implementing derivation primitives for 'Cole' addresses.
- 'Bcc.Address.Style.Icarus' module implementing derivation primitives for 'Icarus' addresses.

### Changed

N/A

### Removed

N/A
