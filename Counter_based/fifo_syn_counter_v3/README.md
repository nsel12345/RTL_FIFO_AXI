# Synchronous FIFO: Counter Architecture (Version 3)

## 📌 Version Objective
This iteration finalizes the baseline Counter Architecture by resolving a critical testbench lifecycle bug discovered in Version 2. The primary objective is to implement a non-blocking mailbox retrieval mechanism to ensure the Driver gracefully powers down the data bus at the end of the simulation, rather than hanging and repeating the final transaction.

## 🏗️ Architecture Details
The underlying RTL design (`design.sv`) remains identical to previous versions. It utilizes a standard counter-based architecture to track the fill level, combinational logic for the `full` and `empty` flags, and operates with a 1-cycle read/write latency.

## 🧪 Verification Strategy (The Driver Update)
In Version 2, the Driver class utilized a blocking `mb.get(tr)` method inside a continuous `forever` loop. When the Generator exhausted its transaction limit, the Driver stalled indefinitely, holding the physical pins at their final state. If the last state included an active write, the FIFO would inadvertently overflow. 

In Version 3, the Driver's logic is fundamentally upgraded:
* **Non-Blocking Retrieval:** The Driver now uses `mb.try_get(tr)`. 
* **Safe Default State:** If the mailbox is empty (meaning the Generator has finished), the `else` branch of the Driver actively forces `wr_en <= 0` and `rd_en <= 0`.
* This guarantees that when the testbench runs out of stimulus, the data bus goes quiet rather than artificially stressing the DUT.

## 📈 Waveform Analysis
The included `fifo_syn_counter_tb3_v3.png` waveform perfectly demonstrates the successful testbench patch:
1.  **Stable Bus History:** Just like V2, the `din` bus holds its state beautifully during idle clock cycles.
2.  **Graceful Shutdown:** At the end of the simulation (starting around 600ns), the transaction queue empties. The waveform clearly shows both `wr_en` and `rd_en` dropping strictly to `0`. 
3.  **Boundary Protection:** Because the enable signals are correctly grounded at the end of the test, the `push_cnt` halts, and the internal FIFO is no longer artificially filled. The simulation concludes in a safe, predictable state.
