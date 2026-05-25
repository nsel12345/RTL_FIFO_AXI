Counter based FIFO versions in this folder.
# Synchronous FIFO: Counter Architecture

## 📌 Overview
This directory contains the baseline implementation of a Synchronous FIFO. The design utilizes a straightforward **Counter-Based** architecture to track the internal memory fill level. 

Rather than presenting a single final file, this directory is split into three chronological versions (`v1`, `v2`, and `v3`). This structure documents the iterative verification process, showcasing how the Object-Oriented (OOP) testbench was incrementally hardened to simulate realistic hardware buses and handle edge-case simulation lifecycles.

## 🏗️ RTL Architecture Summary
The underlying hardware design (`design.sv`) remains consistent across all three versions:
* **Tracking:** An internal `count` register increments on a valid push and decrements on a valid pop.
* **Flags:** The `full` and `empty` boundary flags are combinationally driven directly by the counter state.
* **Latency:** The architecture operates with a standard **1-cycle latency** for both read and write operations.

## 🧪 The Verification Journey
The progression from Version 1 to Version 3 focuses entirely on refining the SystemVerilog OOP testbench to achieve a cycle-accurate, realistic simulation environment.

### [Version 1: The Baseline]
* **Implementation:** Established the base Generator, Driver, Monitor, and Scoreboard classes. The Generator creates unconstrained randomized traffic (50/50 read/write probability).
* **Observation:** The `din` payload randomized on every clock cycle regardless of the `wr_en` state, creating unrealistic visual noise on the waveform (though the DUT correctly ignored it).

### [Version 2: Bus Stabilization]
* **Implementation:** Upgraded the Generator with state-tracking logic. If a transaction lacks an active write enable, the `din` bus holds its previous valid state rather than generating garbage. 
* **Observation:** Achieved a highly readable, realistic waveform. However, a testbench lifecycle bug was discovered: because the Driver used a blocking `get()` request, it hung at the end of the simulation, continuously driving the final transaction and artificially overflowing the FIFO.

### [Version 3: Graceful Shutdown (Final)]
* **Implementation:** Upgraded the continuous Driver loop to use a non-blocking `try_get()` mechanism. 
* **Result:** When the Generator exhausts its transactions, the Driver safely drops into an `else` branch, actively grounding the `wr_en` and `rd_en` pins to `0`. The simulation now powers down gracefully without artificially stressing the design. This is the definitive, stable version of the Counter architecture.
