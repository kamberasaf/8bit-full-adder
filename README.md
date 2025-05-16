# 8-Bit Full Adder with Register Interface

This project implements an 8-bit full adder in Verilog with registered inputs and outputs. It will be expanded to include a register interface for configuration and control.

## Current Implementation

The current version includes:
- 1-bit full adder module (`fa_1bit`)
- 8-bit full adder module (`dut_8bit_addr`) that uses eight 1-bit full adders
- Registered inputs (`Value_a`, `Value_b`, `Data_val`)
- Registered outputs (`Sum_result`, `Sum_carry`, `Data_ready`)
- Testbench (`dut_test_bench`) for verification

## How to Use

1. Open the project in Vivado
2. Run the simulation
3. View the waveform to verify operation

## Future Enhancements

The project will be expanded to include:
1. Three 8-bit registers:
   - Control Register (0x0): Contains the offset_enable bit
   - Offset Value Register (0x1): Holds an 8-bit offset value
   - General Purpose Register (0x2): 8-bit general storage

2. Register Interface with signals:
   - Des_address (3 bits): Register selection
   - Des_value (8 bits): Value to write
   - Des_req_valid (1 bit): Transaction indicator
   - Des_wr_rd (1 bit): Write/read selection
   - Des_rd_vaue (8 bits): Read data output

## Implementation Details

The adder is built by chaining eight 1-bit full adders together, with the carry out of each adder connected to the carry in of the next adder.

All inputs and outputs are registered to ensure proper synchronization with the clock domain.