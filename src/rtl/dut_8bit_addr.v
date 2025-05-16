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
    output reg [WIDTH-1:0] Sum_result,
    output reg Sum_carry, Data_ready
);
    reg [WIDTH-1:0] value_a_reg, value_b_reg;
    reg data_val_reg;
    
    // Sample input data
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            value_a_reg <= 0;
            value_b_reg <= 0;
            data_val_reg <= 1'b0;
        end
        else begin
            value_a_reg <= Value_a;
            value_b_reg <= Value_b;
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
    
    // Sample output data
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Sum_result <= 0;
            Sum_carry <= 1'b0;
        end
        else begin
            Sum_result <= sum_wire;
            Sum_carry <= carry_wire[WIDTH];
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
endmodule