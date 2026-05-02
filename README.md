# RTL_FIFO_AXI
This repository showcases the step-by-step architectural evolution of a high-speed data buffer (FIFO) written in SystemVerilog—starting from a basic counter-based memory and optimizing it into a high-performance First-Word Fall-Through (FWFT) pipeline.

(Note: All designs in this repository are currently implemented as Synchronous FIFOs).

Because digital design requires rigorous testing, a major focus of this project was learning how to build a robust verification environment. This repository includes custom, object-oriented testbenches built to aggressively stress-test the pipeline with constrained-random data traffic, edge-case full/empty flags, and multi-cycle pipeline stalls.

Tools: EDA Playground- Aldec Riviera Pro

🚧 Work in Progress: Since this repository serves as a learning notebook, I am actively working on some parts of it, learning, editing, and resolving bugs. Some folders are still being updated with new waveforms, documentation, and optimized code.

-----------------------------------------

📂 Repository Organization

The repository is structured to show the evolution of the architecture. Each version contains its own isolated design, testbench, waveform captures, and specific README.md detailing the changes.

```text
📦 RTL-FIFO-AXI
 ┣ 📂 Counter_based
 ┃ ┣ 📂 fifo_syn_counter_v1
 ┃ ┃ ┣ 📜 design.sv
 ┃ ┃ ┣ 📜 fifo.if
 ┃ ┃ ┣ 📜 testbench.sv
 ┃ ┃ ┣ 🖼️ waveform_image
 ┃ ┃ ┗ 📜 README.md
 ┃ ┣ 📂 fifo_syn_counter_v2
 ┃ ┗ 📂 fifo_syn_counter_v3
 ┃
 ┣ 📂 Pointer_based
 ┃ ┣ 📂 fifo_syn_pointer_v1
 ┃ ┗ 📂 fifo_syn_pointer_v2
 ┃
 ┗ 📂 FWFT_AXI
   ┣ 📂 fifo_syn_fwft_axi_v1
   ┃ ┣ 📜 design.sv  (FWFT Wrapper)
   ┃ ┣ 📜 fifo_syn_pointer.sv
   ┃ ┣ 📜 fifo.if
   ┃ ┣ 📜 testbench.sv
   ┃ ┣ 🖼️ waveform_image
   ┃ ┗ 📜 README.md
   ┗ 📂 fifo_syn_fwft_axi_v2

📄 File Type Descriptions

design.sv: Top-level module design file (For AXI versions, this acts as the FWFT wrapper).

fifo_syn_pointer.sv: The native pointer-based submodule utilized within the AXI FWFT designs.

fifo_if.sv: Interface module connecting the testbench to the DUT (Device Under Test).

testbench.sv: Contains all OOP verification classes (Generator, Driver, Monitor, Scoreboard, Environment) and the top-level module instantiation.
