# 4x4 Output-Stationary Systolic Array Matrix Multiplier

A synthesizable, high-performance 2D Output-Stationary Systolic Array architecture implemented in Verilog HDL. Designed to accelerate $4 \times 4$ matrix multiplication for INT8 data types, serving as a core processing block for edge AI/ML hardware accelerators.

---

## 1. Architecture Overview

The system processes two $4 \times 4$ matrices ($A$ and $B$) using a $2\text{D Mesh}$ of 16 Processing Elements (PEs). It employs an **Output-Stationary** dataflow pattern, where partial sums remain within each PE's local accumulator while input matrices stream through the grid horizontally and vertically.

### Key Technical Specifications
- **Array Size:** $4 \times 4$ (16 PEs)
- **Input Data Width:** 8-bit signed/unsigned integer (`DATA_WIDTH = 8`)
- **Accumulator Precision:** 32-bit integer (`ACC_WIDTH = 32`) to prevent overflow
- **Throughput:** 1 MAC operation per PE per clock cycle
- **Target Flow:** Verilator Simulation, Yosys Logic Synthesis, OpenLANE Sky130 ASIC flow

---

## 2. Processing Element (PE) Design

Each PE contains a Multiply-Accumulate (MAC) unit alongside pipeline registers to pass data to neighboring elements:

$$\text{Out}_{\text{accum}} \Leftarrow \text{In}_{\text{accum}} + (\text{In}_A \times \text{In}_B)$$

- **`in_a` / `out_a`:** 8-bit horizontal data path (pipelined across rows)
- **`in_b` / `out_b`:** 8-bit vertical data path (pipelined down columns)
- **`out_acc`:** 32-bit internal accumulated output

---

## 3. Interface & I/O Signals

### Top-Level Module (`systolic_array.v`)

| Signal Name | Direction | Bit Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | System Clock |
| `rst_n` | Input | 1 | Asynchronous Active-Low Reset |
| `start` | Input | 1 | Pulse to trigger matrix multiplication execution |
| `in_a` | Input | 4 x 8-bit | Streamed matrix $A$ inputs (Row-skewed) |
| `in_b` | Input | 4 x 8-bit | Streamed matrix $B$ inputs (Column-skewed) |
| `done` | Output | 1 | High when computation cycle completes |
| `out_c` | Output | 16 x 32-bit | Parallel $4 \times 4$ matrix result output bus |

---

## 4. Verification & Toolchain

This repository uses an open-source, high-throughput verification flow:
- **Simulation Engine:** [Verilator](https://www.veripool.org/verilator/) (C++ Testbench driven)
- **Waveform Inspection:** [GTKWave](http://gtkwave.sourceforge.net/)
- **Synthesis Engine:** [Yosys](https://yosyshq.net/yosys/)

### Running Regressions & Tests
```bash
# Build and run C++ testbench via Verilator
make sim

# Run automated regression test suite across random matrices
python3 run_regressions.py