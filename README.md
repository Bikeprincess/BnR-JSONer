# JSONer [Zpět](../README.md)

[![Made For B&R](https://github.com/hilch/BandR-badges/blob/main/Made-For-BrAutomation.svg)](https://www.br-automation.com)

JSONer library for serialize and deserialize JSON for B&R PLC.

## Usage

There are 2 Function for user:
- JSON_serialize: create JSON string from variable
  - `pVarName`: PV name with program name, if it's not global var.
  - `pUserVarName`: ADR of string with variable name - only used with array.
  - `pOut`: ADR of buffer.
  - `sizeOut`: size of output buffer.
  - `size`: IN/OUT variable for check output size.
- JSON_deserialize: parse JSON string into PV
  - `pVarName`: PV name with program name, if it's not global var.
  - `pUserVarName`: ADR of string with variable name - only used with array. Internally <> 0 and name is not used. Set to 0, if PV is `STRUCT`.
  - `pIn`: ADR of JSON string.
  - `sizeIn`: size of input string - for internal check.

Output is `ENUM` `JSONer_Status_e`: `JSONer_Ok` is 0 and another states are Errors.

Just call the function to generate values.

## Limitation / Known bugs

- Array must start with index 0 and be positive. Dimension can be only one. 
- `ENUMS` not supported. Use `UDINT`.
- `WSTRING` is not implemented, but have place in program.
- Input `STRING` are not modified, only copied to output. That's mean, that `$n` are not transfered to `\n` etc.
- Speed and memory usage?

## Changelog

### V1.0.0

Fix bool -> Remove Quoation and do small alphabet
Fix input array

### V1.0.0

First usable version
