# Matched filter & pn_generator

## **STATUS:** work in progress

### First part:
*Work in QuestaSim*
- [x] `PN generator`
- [x] **Base TB** `"PN generator"`
- [x] `Matched filter`
- [x] **Base TB** `"Matched filter"`
- [ ] Full verification. (Coverage, SVA, test reset, improve Scoreboard)
- [ ] UVM
- [ ] Upload coef from .mem (write .py)
- [ ]

### Second part:
*Design translation in Vivado. Create IP-cores. Verification wrapper*
- [x] Add a `PicoRV32` (RISC-V)
- [ ] Add support for the `AXI4-Lite` interface to the source code
- [ ] Package ip-core `PN generator`
- [ ] Package ip-core `Matched filter`
- [x] Package ip-core `PicoRV32`
- [ ] Access to reg space of ip-cores
- [ ] Verification