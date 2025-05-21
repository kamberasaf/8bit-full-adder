# Project Requirements

## Basic 8-bit Full Adder
1. Design an 8-bit full adder using only a one-bit full adder
2. Implement the design in Verilog:
   
   a. Call the new module – dut_8bit_addr
   
   b. Create a test bench (a module call dut_test_bench)
   
   c. Instantiate the dut in the test bench
   
4. The data coming into the design (value_a, value_b, data_val) should be sampled first (using the clk and reset)
5. The data coming out of the design should also be sampled (sum_result, sum_carry, data_ready)

## Design Expansion
In this section, the full adder design will be expanded to include:

1. Three 8-bit registers:
   a. Address 0x0 - control register:
      • This register contains 1 bit – offset_enable, in bit 0 of the register (other bits are don't care). When set to 1 – an offset is added to all calculation.
   
   b. Address 0x1 – offset_value:
      • This register holds 8-bit value which is added to all calculations
   
   c. Address 0x2 – general_purpose:
      • This register has 8 bits which are stored on any write, the value isn't used at this stage

3. Add an interface which enables writing to these registers:
   • Note - the interface to writing to register is not related to the interface of the Adder

## Interface Definition

| Signal name  | Width | Direction | Description |
|--------------|-------|-----------|-------------|
| Des_address  | 3     | Input     | Indicates to which of the 3 registers the transaction is related |
| Des_value    | 8     | Input     | Value written to one of the registers |
| Des_req_valid| 1     | Input     | 1 - Indicates a transaction, 0 – no transaction is made |
| Des_wr_rd    | 1     | Input     | 1 - Write transaction, 0 – read transaction |
| Des_rd_vaue  | 8     | Output    | Output of the read register according to address signal |

## Testbench Requirements
Create a test bench in which you instantiate the module:
- Create clock
- Create a reset
- Drive different values on the inputs and check that the outputs are correct
- Drive value to the offset register and check output is adjusted accordingly

## Extra Assignment (Not Mandatory)
Access the internal registers through the "DES" bus:
- Write to all registers
- Read from all registers
