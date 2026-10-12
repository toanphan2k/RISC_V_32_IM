# RISC-V RV32IM Core

> Note: This document was generated with AI assistance and may be updated manually as the project evolves.

This repository contains a simple SystemVerilog implementation of a 32-bit RISC-V processor based on the RV32IM instruction set.

The design targets the RV32I base integer ISA and includes the M extension for integer multiplication and division. It is intended as a learning-oriented reference for understanding the RISC-V architecture and a simple hardware datapath implementation.

## Features

- 32-bit RISC-V integer core
- RV32I base instruction set support
- RV32M multiplication and division support
- ALU and control logic implemented in SystemVerilog
- Pipeline stage organization with separate decode, execute, memory, and write-back logic
- Instruction and architecture documentation included in the docs folder

## Project Structure

- `rtl/core/` – processor core implementation and stage logic
- `rtl/pkg/` – package definitions and shared data structures
- `tb/` – basic testbenches for verification
- `docs/` – ISA and microarchitecture references

## Supported Instruction Groups

- Arithmetic and logical instructions
- Control-flow instructions (`BEQ`, `BNE`, `JAL`, `JALR`)
- Memory access instructions (`LW`, `SW`, `LB`, `SB`, etc.)
- Shift and compare operations
- Integer multiply/divide instructions from the M extension

## Example Use

This project is useful for:

- studying RISC-V ISA encoding and execution flow
- understanding a simple RV32IM datapath design
- experimenting with SystemVerilog CPU architecture
- extending the core with additional features or peripherals

## Documentation

See the files in the `docs/` directory for architecture overviews and instruction-set references:

- `docs/RISCV_ISA_Architect.md`
- `docs/instruction_set.md`

## Notes

This is a compact educational implementation rather than a full commercial processor. It is best suited for learning, simulation, and architectural experimentation.
