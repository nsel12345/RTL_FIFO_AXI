***

```markdown
# Synchronous FIFO: Counter Architecture (Version 2)

## 📌 Version Objective
This iteration builds upon the baseline Counter Architecture (V1) by refining the verification environment. The primary objective is to clean up the simulated data bus, ensuring that the input data payload (`din`) retains its previous state rather than generating random garbage when no active write is occurring. 

## 🏗️ Architecture Details
The underlying RTL design remains identical to Version 1. It utilizes a standard counter-based architecture to track the fill level and combinationally drive the `full` and `empty` flags, operating with a 1-cycle read/write latency.

## 🧪 Verification Strategy
The Object-Oriented (OOP) testbench was heavily modified in the Generator class. State-tracking logic was introduced to monitor the `wr_en` flag. If a transaction is generated without an active write enable, the randomization of `din` is overridden, and the previous valid data payload is driven onto the bus instead. This simulates a realistic, stable hardware bus and significantly cleans up waveform generation.

**Known Simulation Edge-Case:**
During testing, an edge-case was discovered regarding the Driver class lifecycle. Because the Generator yields a finite number of transactions while the Driver runs in a continuous loop, the Driver hangs on its final mailbox request. If the final generated transaction happens to have `wr_en` asserted, the Driver will continuously drive that final state into the physical pins until the testbench delay expires, causing the FIFO to inadvertently fill up at the end of the simulation. This behavior is documented in the waveform and is targeted for patching in Version 3.

## 📈 Waveform Analysis
The included `fifo_syn_counter_tb2_v2.png` waveform confirms the updated testbench mechanics:
1.  **Clean Data Bus:** The `din` bus no longer toggles continuously; it successfully holds its state whenever `wr_en` is low.
2.  **End-of-Simulation Hang:** At approximately 300ns, the Generator exhausts its transaction pool. The waveform accurately captures the Driver edge-case, showing `wr_en` holding high and repeatedly pushing the final data payload until the internal logic correctly asserts the `full` flag to prevent overflow.
