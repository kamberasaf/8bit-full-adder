`timescale 1ns / 1ps
module fa_1bit(
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | ((a ^ b) & cin);
endmodule

module dut_8bit_addr #(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] Value_a, Value_b,
    input Data_val, clk, reset_n,
    
    // DES Bus Interface
    input [WIDTH-1:0] Des_value,           // Value for write
    input [2:0] Des_address,               // Address for register transaction
    input Des_req_valid,                   // 1 = Transaction, 0 = No transaction
    input Des_wr_rd,                       // 1 = Write, 0 = Read
    output reg [WIDTH-1:0] Des_rd_value,   // Read output
    
    output reg [WIDTH-1:0] Sum_result,
    output reg Sum_carry, Data_ready
    
);
    reg [WIDTH-1:0] value_a_reg, value_b_reg;
    reg data_val_reg;
    
    // DES Registers
    reg [7:0] control_register; // Address 0x0
    reg [7:0] offset_value;     // Address 0x1
    reg [7:0] general_purpose;  // Address 0x2
    
    // Sample input data
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            value_a_reg  <= 0;
            value_b_reg  <= 0;
            data_val_reg <= 1'b0;
        end
        else begin
            value_a_reg  <= Value_a;
            value_b_reg  <= Value_b;
            data_val_reg <= Data_val;
        end
    end
    
    wire [WIDTH-1:0] sum_wire;
    wire [WIDTH:0] carry_wire;
    assign carry_wire[0] = 1'b0;
    
    // Generate 8-bit Full Adder using 1-bit Full Adders
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : fa_gen
            fa_1bit fa_inst (
                .a(value_a_reg[i]),
                .b(value_b_reg[i]),
                .cin(carry_wire[i]),
                .sum(sum_wire[i]),
                .cout(carry_wire[i+1])
            );
        end
    endgenerate
    
    // Intermediate wires for adder result and offset calculation
    wire [WIDTH-1:0] adder_result;
    wire adder_carry;
    wire [WIDTH:0] offset_result;

    // Connect the basic adder outputs
    assign adder_result = sum_wire;
    assign adder_carry = carry_wire[WIDTH];

    // Calculate the offset result
    assign offset_result = {1'b0, adder_result} + {1'b0, offset_value};
    
   // Sample output data with offset logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Sum_result <= 0;
            Sum_carry <= 1'b0;
        end
        else begin
            if (control_register[0]) begin
                // Use offset_result when enabled
                Sum_result <= offset_result[WIDTH-1:0];
                Sum_carry <= offset_result[WIDTH] | adder_carry; // Preserve the original carry
            end else begin
                // Use normal adder result
                Sum_result <= adder_result;
                Sum_carry <= adder_carry;
            end
        end
    end
    
    // Generate Data_ready signal
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Data_ready <= 1'b0;
        end
        else begin
            Data_ready <= data_val_reg; // One cycle after input is valid
        end
    end
    
    // Expanded registers initialization and write logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            control_register <= 0;    // Address 0x0
            offset_value     <= 0;    // Address 0x1
            general_purpose  <= 0;    // Address 0x2
        end
        else if (Des_req_valid && Des_wr_rd) begin // Write operation
            case (Des_address)
                3'b000: control_register <= Des_value;
                3'b001: offset_value     <= Des_value;
                3'b010: general_purpose  <= Des_value;
                default: ; // Do nothing
            endcase
        end
    end
    
    // Register Read Logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Des_rd_value <= 8'b0;
        end
        else if (Des_req_valid && !Des_wr_rd) begin // Read operation
            case (Des_address)
                3'b000: Des_rd_value <= control_register;
                3'b001: Des_rd_value <= offset_value;
                3'b010: Des_rd_value <= general_purpose;
                default: Des_rd_value <= 8'b0;
            endcase
        end
    end
    
endmodule