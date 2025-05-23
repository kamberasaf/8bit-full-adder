`timescale 1ns / 1ps
module dut_test_bench();
    // Inputs
    reg [7:0] Value_a, Value_b;
    reg Data_val, clk, reset_n;
    // DES Bus Interface
    reg [2:0] Des_address;
    reg [7:0] Des_value;
    reg Des_req_valid;
    reg Des_wr_rd;
    // Outputs
    wire [7:0] Sum_result;
    wire Sum_carry, Data_ready;
    wire [7:0] Des_rd_value;
    
    // Instantiate the DUT
    dut_8bit_addr dut(
        .Value_a(Value_a),
        .Value_b(Value_b),
        .Data_val(Data_val),
        .clk(clk),
        .reset_n(reset_n),
        .Des_address(Des_address),
        .Des_value(Des_value),
        .Des_req_valid(Des_req_valid),
        .Des_wr_rd(Des_wr_rd),
        .Des_rd_value(Des_rd_value),
        .Sum_result(Sum_result),
        .Sum_carry(Sum_carry),
        .Data_ready(Data_ready)
    );
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;   // 10ns Period / 100 Mhz Freq.
    
    // Test sequence
    initial begin
        // Initialize signals
        reset_n = 0; // Enable reset
        Value_a = 8'b0;
        Value_b = 8'b0;
        Data_val = 0;
        Des_address = 3'b000;
        Des_value = 8'b0;
        Des_req_valid = 0;
        Des_wr_rd = 0;
        
        // Reset for one clock cycle
        #10 reset_n = 1; // Disable reset 
        #10; // Wait another cycle after reset
        
        // ------------------ Basic Adder Tests ---------------
        // Test Case 1: 5 + 3 = 8 (Basic addition)
        Value_a = 8'd5; Value_b = 8'd3; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result to propagate (2 cycles)
        
        // Check result
        if (Sum_result !== 8'd8 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 1 failed! Expected 8, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 1 passed!");
        end
        
        // Test Case 2: 200 + 55 = 255 (Near max value)
        Value_a = 8'd200; Value_b = 8'd55; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result
        if (Sum_result !== 8'd255 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 2 failed! Expected 255, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 2 passed!");
        end
        
        // Test Case 3: 255 + 1 = 0 with carry (Overflow)
        Value_a = 8'd255; Value_b = 8'd1; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result (should have carry)
        if (Sum_result !== 8'd0 || Sum_carry !== 1'b1) begin
            $display("ERROR: Test Case 3 failed! Expected 0 with carry, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 3 passed!");
        end
        
        // Test Case 4: 0 + 0 = 0 (Zero addition)
        Value_a = 8'd0; Value_b = 8'd0; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result
        if (Sum_result !== 8'd0 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 4 failed! Expected 0, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 4 passed!");
        end
        
        // ------------- Register Write & Read Tests ---------
        // Test Case 5: Write & Read Offset Register
        #20 Des_address = 3'b001; Des_value = 8'd10;  // Write 10 to offset register
        Des_req_valid = 1; Des_wr_rd = 1;
        #10 Des_req_valid = 0; // End transaction
        
        // Read Offset Register (Address 0x1)
        #20 Des_address = 3'b001;
        Des_req_valid = 1; Des_wr_rd = 0;
        #10 Des_req_valid = 0; // End transaction

        // Check result
        if (Des_rd_value !== 8'd10) begin
            $display("ERROR: Test Case 5 failed! Expected 10, got %d", Des_rd_value);
        end else begin
            $display("Test Case 5 passed!");
        end
        
        // Test Case 6: Enable Offset & Test Addition with Offset
        #20 Des_address = 3'b000; Des_value = 8'b00000001; // Set bit 0 to 1
        Des_req_valid = 1; Des_wr_rd = 1;
        #10 Des_req_valid = 0;
        #20; // Wait for register update to take effect
        
        // Max + 1 with Offset (10) - should give 0+10 = 10 with carry
        #20 Value_a = 8'd255; Value_b = 8'd1; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result to propagate

        // Check result (255 + 1 + 10 offset = 266, which overflows to 10 with carry)
        if (Sum_result !== 8'd10 || Sum_carry !== 1'b1) begin
            $display("ERROR: Test Case 6 failed! Expected 10 with carry, got %d with carry %b", Sum_result, Sum_carry);
        end else begin  
            $display("Test Case 6 passed! - 255 + 1 + 10(offset) = 266 -> 10 with carry");
        end

        // Test Case 7: Write & Read General Purpose Register
        #20 Des_address = 3'b010; Des_value = 8'hA5;  // Write A5 to general purpose register
        Des_req_valid = 1; Des_wr_rd = 1;
        #10 Des_req_valid = 0;

        // Read general purpose register
        #20 Des_address = 3'b010;
        Des_req_valid = 1; Des_wr_rd = 0;
        #10 Des_req_valid = 0;

        // Verify read value
        if (Des_rd_value !== 8'hA5) begin
            $display("ERROR: Test Case 7 failed! Expected A5, got %h", Des_rd_value);
        end else begin
            $display("Test Case 7 passed! - General purpose register read/write successful");
        end

        // Test Case 8: Disable Offset & Verify Normal Addition
        #20 Des_address = 3'b000; Des_value = 8'b00000000;  // Clear bit 0 to disable offset
        Des_req_valid = 1; Des_wr_rd = 1;
        #10 Des_req_valid = 0;
        #20; // Wait for register update to take effect

        // Test normal addition again to ensure offset is disabled
        #20 Value_a = 8'd5; Value_b = 8'd3; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result to propagate

        // Check result (should be 8 with no offset)
        if (Sum_result !== 8'd8 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 8 failed! Expected 8, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 8 passed! - Offset disabled correctly");
        end

        // End simulation
        #50 $finish;
    end

    // ------------------ Monitor Results ------------------
    initial begin
        $monitor("Time: %0t | A:%d | B:%d | Sum: %d | Carry: %b | Ready: %b | DES[addr:%d val:%d rw:%b req:%b rd:%d] | Ctrl:%b Offset:%d",
                $time, Value_a, Value_b, Sum_result, Sum_carry, Data_ready, 
                Des_address, Des_value, Des_wr_rd, Des_req_valid, Des_rd_value,
                dut.control_register[0], dut.offset_value);
    end
endmodule
