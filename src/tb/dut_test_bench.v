`timescale 1ns / 1ps
module dut_test_bench();
    // Inputs
    reg [7:0] Value_a, Value_b;
    reg Data_val, clk, reset_n;
    // Outputs
    wire [7:0] Sum_result;
    wire Sum_carry, Data_ready;
    
    // Instantiate the DUT
    dut_8bit_addr dut(
        .Value_a(Value_a),
        .Value_b(Value_b),
        .Data_val(Data_val),
        .clk(clk),
        .reset_n(reset_n),
        .Sum_result(Sum_result),
        .Sum_carry(Sum_carry),
        .Data_ready(Data_ready)
    );
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;   // 10ns Period / 100 Mhz Freq.
    
    // Optional: Waveform dumping
   // initial begin
    //    $dumpfile("adder_test.vcd");
     //   $dumpvars(0, dut_test_bench);
    //end
    
    // Test sequence
    initial begin
        // Initialize signals
        reset_n = 0; // This will reset
        Value_a = 8'b0;
        Value_b = 8'b0;
        Data_val = 0;
        
        // Reset for one clock cycle
        #10 reset_n = 1;
        #10; // Wait another cycle after reset
        
        // ------------------ Basic Adder Tests ---------------
        // Test Case 1: 5 + 3 = 8
        Value_a = 8'd5; Value_b = 8'd3; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result to propagate (2 cycles)
        
        // Check result
        if (Sum_result !== 8'd8 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 1 failed! Expected 8, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 1 passed!");
        end
        
        // Test Case 2: 200 + 55 = 255
        Value_a = 8'd200; Value_b = 8'd55; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result
        if (Sum_result !== 8'd255 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 2 failed! Expected 255, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 2 passed!");
        end
        
        // Test Case 3: 255 + 1 = 0 with carry
        Value_a = 8'd255; Value_b = 8'd1; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result (should have carry)
        if (Sum_result !== 8'd0 || Sum_carry !== 1'b1) begin
            $display("ERROR: Test Case 3 failed! Expected 0 with carry, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 3 passed!");
        end
        
        // Additional Test Case 4: 0 + 0 = 0
        Value_a = 8'd0; Value_b = 8'd0; Data_val = 1;
        #10 Data_val = 0;
        #20; // Wait for result
        
        // Check result
        if (Sum_result !== 8'd0 || Sum_carry !== 1'b0) begin
            $display("ERROR: Test Case 4 failed! Expected 0, got %d with carry %b", Sum_result, Sum_carry);
        end else begin
            $display("Test Case 4 passed!");
        end
        
        // End simulation
        #50 $finish;
    end
    
    // ------------------ Monitor Results ------------------
    initial begin
        $monitor("Time: %0t | A:%d | B:%d | Sum: %d | Carry: %b | Ready: %b | Data_val: %b ",
                $time, Value_a, Value_b, Sum_result, Sum_carry, Data_ready, Data_val);
    end
endmodule