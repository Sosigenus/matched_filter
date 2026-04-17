# Matched filter & pn_generator
A matched filter is designed to detect a known signal against a background of noise. it maximizes the signal-to-noise ratio <br>
Mathematically, this is the operation of **convolving** an input signal with a time-reversed copy of the desired signal:<br>
$$y[n] = \sum_{k=0}^{N-1} x[n-k] \cdot h[k]$$
## **STATUS:** work in progress

<details>
<summary> Changelog </summary>

### [v1.0] - 2026-03-28
- **Init commit**

### [v1.1] - 2026-04-17
- **Added project Vivado**
- **Added AXI**
- **Added BFM**
- **Change architecture** (interface)

</details>

## Board IUPAI ZYNQ7020

[!Board IUPAI ZYNQ7020](./img/board.jpg)

**Architecture (RTL):**
1. **Delay line:**: A shift register for storing the last samples
2. **Multipliers:**: Parallel multiplication by coefficients
3. **Adder tree:**: Adding up all products to get results

## Control via AXI4-Lite
All module settings are placed in the register space and are accessible via the **AXI4-Lite** bus.

### Customization options
- **Soft Reset (SW_RST):** Reset the conveyor and delay line without restarting the entire FPGA.
- **Dynamic loading of coefficients:** Writing the reference signal (vector `h[n]`) to registers.
- **Status reading:** Monitoring the filter status and reading the current values of the delayed counts.

### Register map `Design`
| Name           | Offset      | Range |
| :------------- | :---------- | :---: |
| PN_generator   | 0x44A0_0000 | 4K    |
| Matched_filter | 0x44A1_0000 | 64K   |
| BRAM_ROM       | 0x0000_0000 | 8K    |
| BRAM_RAM       | 0xC000_0000 | 8K    |

### Register map `MATCHED_FILTER`
| Offset | Bits       | Register         | Access   |
| :--- | :----------- | ---------------- | :------: |
| `0x00` | Bit 31     | SW_RST           | R/W      |
| `0x00` | Bit 30..0  | Reserved         | -        |
| `0x04` | Bit 31..0  | Coefficient №0   | R/W      |
| `0x08` | Bit 31..0  | Coefficient №1   | R/W      |
| ...    | ...        | ...              | ...      |
| `0x40` | Bit 31..0  | Coefficient №15  | R/W      |

### Register map `PN_generator`
| Offset | Bits       | Register         | Access   |
| :--- | :----------- | ---------------- | :------: |
| `0x00` | Bit 31     | SW_RST           | R/W      |
| `0x00` | Bit 30..0  | Reserved         | R/W      |
| `0x04` | Bit 4..0   | SEED_INIT        | R/W      |
| `0x04` | Bit 7..5   | Reserved         | -        |
| `0x04` | Bit 11..8  | OS_INIT          | R/W      |
| `0x04` | Bit 31..12 | reserved         | -        |

## Open a project in Vivado
* Create a project
* Add ip_cores. `Settings` -> `IP Repository`
* In tcl-console open directory project (use command example: `cd ~/project_m_f/vivado`)
* In tcl-console run design_1.tcl (use command: `source ./design_1.tcl`)


## Structure checkbox
### First part:
*Work in QuestaSim*
- [x] `PN generator`
- [x] **Base TB** `"PN generator"`
- [x] `Matched filter`
- [x] **Base TB** `"Matched filter"`
- [ ] Full verification. (Coverage, SVA, test reset, improve Scoreboard)
- [ ] `UVM`
- [ ] Upload coef from .mem (write .py)

### Second part:
*Design translation in Vivado. Create IP-cores. Verification wrapper*
- [x] Add a `PicoRV32` (RISC-V)
- [x] Add support for the `AXI4-Lite` interface to the source code
- [x] Package ip-core `PN generator`
- [x] Package ip-core `Matched filter`
- [x] Package ip-core `PicoRV32`
- [x] Access to reg space of ip-cores
- [x] Verification
- [ ] Remake `OOP`
- [ ] Remake architecture (monitor, scoreboard, use class, assert, covergroup, clocking blocks)
- [ ] `UVM`