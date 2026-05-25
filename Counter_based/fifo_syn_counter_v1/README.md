
Intial fifo design and testbench.
# Synchronous FIFO: Counter Architecture (Version 1)

## 📌 Version Objective
This folder contains the initial baseline implementation of a Synchronous FIFO. The primary objective of Version 1 is to establish a working First-In-First-Out data structure utilizing a straightforward **Counter-Based** approach to track the buffer's fill level. 

## 🏗️ Architecture Details
* **Tracking Mechanism:** The design relies on an internal `count` register. The logic increments the counter on a valid `push`, decrements it on a valid `pop`, and holds the value steady if both or neither occur.
* **Flag Generation:** The `full` and `empty` flags are combinationally driven directly by this counter (e.g., `empty = (count == 0)`).
* **Pointers:** The read and write pointers (`rd_ptr`, `wr_ptr`) are simple wrapping counters that dictate the memory addresses.
* **Latency:** This baseline architecture features a standard **1-cycle latency** for both read and write operations.

## 🧪 Verification Strategy
The design is verified using a custom cycle-accurate Object-Oriented (OOP) testbench built in SystemVerilog. 

* **Unconstrained Randomization:** The Generator class creates transactions using unconstrained randomization (`rand bit wr_en`, `rand bit rd_en`), meaning reads and writes have an equal 50/50 probability.
* **Active Data Bus Simulation:** A key feature of this testbench is that the `din` payload is randomized and driven to the bus on every transaction loop, regardless of the `wr_en` state. This accurately simulates a real-world, constantly active data bus. The Scoreboard successfully proves that the DUT correctly ignores this background noise when `wr_en` is deasserted.

## 📈 Waveform Analysis
The included `fifo_syn_counter_tb1_v1.png` waveform confirms several critical behaviors:
1.  **Bus Immunity:** The `din` wire is seen constantly changing values, but the internal `push_cnt` and `count` registers only update when `wr_en` is explicitly high and `full` is low.
2.  **Flag Accuracy:** The `count` increments correctly, and the `empty` flag behaves as expected, dropping low precisely one cycle after the first data word is written.
3.  **Boundary Safety:** Later in the simulation, the FIFO successfully hits its maximum depth (`count == 16`). The `full` flag asserts immediately, preventing the `push` logic from overwriting data despite the testbench continuing to drive `wr_en` high.
