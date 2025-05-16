# 8-Bit Full Adder with Register Interface

This project implements an 8-bit full adder in Verilog with registered inputs and outputs, and an additional register interface for configuration and control.

## Features

1. **Core Functionality:**
   - 8-bit adder built from chained 1-bit full adders
   - Registered inputs and outputs for proper clock synchronization
   - Carry propagation through the adder chain
   - Data ready signal generation

2. **Register Interface:**
   - Three 8-bit configuration registers:
     - Control Register (Address 0x0): Bit 0 enables offset addition
     - Offset Value Register (Address 0x1): Contains the offset value to add
     - General Purpose Register (Address 0x2): Available for general use
   - Simple bus interface with address, data, and control signals

3. **Offset Addition Feature:**
   - When enabled via the control register, adds the offset value to results
   - Properly handles carry bit during offset addition
   - Can be dynamically enabled/disabled during operation

## Files Description

- `dut_8bit_addr.v`: Contains the main design with the 8-bit adder and register interface
- `dut_test_bench.v`: Comprehensive testbench to verify all functionality

## Implementation Details

The adder is built by chaining eight 1-bit full adders together, with the carry out of each adder connected to the carry in of the next adder. All inputs and outputs are registered to ensure proper synchronization with the clock domain.

The register interface provides a simple way to configure the adder's operation. When offset is enabled (by setting bit 0 of the control register), the value in the offset register is added to the basic adder result, allowing for flexible data processing.

## Test Cases

The testbench includes comprehensive verification of all features:

1. Basic addition functionality (5+3=8)
2. Full-range addition (200+55=255)
3. Overflow handling (255+1=0 with carry)
4. Zero addition (0+0=0)
5. Register write/read operations
6. Offset addition with carry propagation (255+1+10=10 with carry)
7. General purpose register functionality
8. Offset enable/disable verification

## Future Enhancements

Possible future improvements include:
- Parameterized design for variable bit widths
- Additional arithmetic operations (subtraction, multiplication)
- Error detection and handling
- More advanced bus interface with timing controls

## Usage

To use this design:
1. Instantiate the `dut_8bit_addr` module in your project
2. Connect the required inputs and outputs
3. Use the DES bus interface to configure the registers as needed
4. Provide input values and sample the results on each clock cycle

## Simulation

The design has been verified through simulation in Vivado. To reproduce:
1. Create a new project in Vivado
2. Add both source files
3. Run the simulation
4. View the waveform to observe operation