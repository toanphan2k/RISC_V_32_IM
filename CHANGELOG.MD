# Changelog

## [0.1.2] - 2026-10-03

### Added
- add IMMEDIATE_GENERATOR module to gen IMM depend on OPCODE

### Changed
- instruction -> instr in input and output for consitency

## [0.1.1] - 2026-10-03

### Added
- add RISCV_ISA_Architect.md to show the structure of instruction and RISCV microarchitect
- add ISA instruction type images and RISCV microarchitect images

### Changed
- migrate images to docs/images

## [0.1.0] - 2026-10-03

### Fixed
- Fixed missing import package in cla_32bit.sv
- Fixed missing ; in stage_ex.sv

### Added
- reg between each stage: reg_if_id, reg_id_ex, reg_ex_mem, reg_mem_wb
- Add REG_ADDR_WIDTH in constant

### Changed
- Change 5 bit of register address [4:0] to [REG_ADDR_WIDTH-1:0]
- Format indent for beauty

## [0.0.12] - 2026-10-02

### Added
- Select signal for execution stage in package
- Add pack control signal in package
- Add stage_ex.sv
- Add local parameter XLEN = 32
### Changed
- Replace MSB 32 with XLEN in all files

## [0.0.11] - 2026-09-30

### Added
- Initialize changelog.md and version.txt

## [0.0.10] - 2026-09-29

### Fixed
- Correct carry-block indexing and overflow handling in the 32-bit CLA.

## [0.0.9] - 2026-09-29

### Added
- Implement the 32-bit carry-lookahead adder.

## [0.0.8] - 2026-09-28

### Added
- Initialize the five RV32IM pipeline stages.

## [0.0.7] - 2026-09-28

### Added
- Add a diagram of the 4-bit carry-lookahead adder.

## [0.0.6] - 2026-09-28

### Changed
- Adapt the 4-bit adder for the 32-bit carry-lookahead design.

## [0.0.5] - 2026-09-28

### Added
- Add the 4-bit carry-lookahead adder and testbench.

## [0.0.4] - 2026-09-27

### Fixed
- Fix GitHub Markdown rendering in the instruction-set documentation.

## [0.0.3] - 2026-09-27

### Changed
- Update the instruction-set documentation and RV32IM package.

## [0.0.2] - 2026-09-25

### Added
- Initialize the ALU and package, with an ALU testbench.

## [0.0.1] - 2026-09-25

### Added
- Add initial Git attributes.

