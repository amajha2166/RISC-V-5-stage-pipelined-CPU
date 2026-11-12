# 32-bit RISC-V 5-Stage Pipelined CPU

A Verilog-based implementation of a 32-bit RISC-V processor using a classic five-stage instruction pipeline, developed and simulated using Xilinx Vivado.

## Project Overview

This project implements an educational RISC-V CPU based on the RV32I instruction format. The processor uses a five-stage pipeline to execute instructions, allowing multiple instructions to be processed simultaneously at different stages.

The project focuses on understanding processor architecture, instruction execution, pipeline operation, data hazards, forwarding, and control hazards.

## Architecture

The processor consists of five pipeline stages:

| Stage | Name | Function |
|---|---|---|
| IF | Instruction Fetch | Fetches instructions from instruction memory |
| ID | Instruction Decode | Decodes instructions and reads registers |
| EX | Execute | Performs ALU operations and branch comparisons |
| MEM | Memory Access | Reads from or writes to data memory |
| WB | Write Back | Writes results into the register file |

### Pipeline Registers

The following registers transfer data between pipeline stages:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

## Features

- 32-bit RISC-V processor datapath
- Five-stage pipelined architecture
- Instruction memory
- Data memory
- 32 general-purpose registers
- Register x0 permanently holds zero
- Arithmetic and logical operations
- Immediate instruction support
- Load and store operations
- Conditional branch instructions
- Data forwarding / bypassing
- Load-use hazard detection and stalling
- Branch flushing
- Behavioral simulation using Vivado XSim

## Supported Instructions

The current implementation supports the following instruction subset:

| Instruction | Operation |
|---|---|
| ADD | Register addition |
| SUB | Register subtraction |
| AND | Bitwise AND |
| OR | Bitwise OR |
| XOR | Bitwise XOR |
| SLL | Logical left shift |
| SRL | Logical right shift |
| SLT | Set less than |
| ADDI | Add immediate |
| LW | Load word |
| SW | Store word |
| BEQ | Branch if equal |
| BNE | Branch if not equal |

**Note:** This is an educational implementation of a subset of RV32I, not a complete RV32I-compliant processor.

## Example Test Program

The processor is initialized with a sample instruction sequence:

```asm
ADDI x1, x0, 10
ADDI x2, x0, 20
ADD  x3, x1, x2
SUB  x4, x2, x1
AND  x5, x1, x2
OR   x6, x1, x2
SW   x3, 0(x0)
LW   x7, 0(x0)
ADDI x8, x7, 1
```

### Expected Results

| Register / Memory | Expected Value |
|---|---:|
| x1 | 10 |
| x2 | 20 |
| x3 | 30 |
| x4 | 10 |
| x5 | 0 |
| x6 | 30 |
| x7 | 30 |
| x8 | 31 |
| Data Memory[0] | 30 |

These are expected values from the sample program; verify them against the final simulation results.

## Tools and Technologies

- **HDL:** Verilog
- **Design and Simulation:** Xilinx Vivado
- **Simulator:** Vivado XSim
- **Version Control:** Git and GitHub

## Project Structure

```text
RISC-V-Pipelined-CPU/
│
├── RISCV_ARC.xpr
│
├── RISCV_ARC.srcs/
│   ├── sources_1/
│   │   └── new/
│   │       ├── riscv_cpu.v
│   │       ├── alu.v
│   │       ├── register_file.v
│   │       └── other design modules
│   │
│   └── sim_1/
│       └── new/
│           ├── tb_riscv_cpu.v
│           └── other testbenches
│
├── screenshots/
│
├── README.md
└── .gitignore
```

The actual folder structure may vary depending on the Vivado project configuration.

## Running the Simulation

1. Install Xilinx Vivado.
2. Clone or download this repository.
3. Open `RISCV_ARC.xpr` in Vivado.
4. Expand **Simulation Sources**.
5. Set `tb_riscv_cpu` as the simulation top module.
6. Select **Run Simulation → Run Behavioral Simulation**.
7. Inspect the waveform and register values.
8. Verify the results against the expected values above.

No physical FPGA board is required for behavioral simulation.

## Future Improvements

- Implement the remaining RV32I instructions.
- Add jump instructions (JAL and JALR).
- Improve branch prediction.
- Add more comprehensive hazard handling.
- Verify performance using larger instruction programs.
- Synthesize and test the processor on an FPGA board.

## Author

**Aman Ojha**

B.Tech – Electronics and Communication Engineering

## License

This project is available for educational and learning purposes. Add an explicit open-source license if you intend to permit reuse under specific terms.
