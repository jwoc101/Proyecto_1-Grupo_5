`timescale 1ns/1ps

module receptor_tb;

reg  [6:0] in;
wire [6:0] raw;
wire [2:0] err;
wire [3:0] data;

// Instantiate DUT (Device Under Test)
receptor uut (
    .in(in),
    .raw(raw),
    .err(err),
    .data(data)
);

// Task to display nicely
task show;
    begin
        $display("in=%b | err=%b | data=%b", in, err, data);
    end
endtask

initial begin
    $dumpfile("receptor_tb.vcd");
    $dumpvars(0, receptor_tb);

    // -----------------------------
    // Test 1: No error
    // Example valid codeword (for data = 1011)
    // (Assumed correct encoding)
    in = 7'b1011010; 
    #10 show();

    // -----------------------------
    // Test 2: Error in bit 1
    in = 7'b1011011; // flip bit 0
    #10 show();

    // -----------------------------
    // Test 3: Error in bit 3
    in = 7'b1011110; // flip bit 2
    #10 show();

    // -----------------------------
    // Test 4: Error in bit 7
    in = 7'b0011010; // flip bit 6
    #10 show();

    // -----------------------------
    // Test 5: Another valid word
    in = 7'b0110011;
    #10 show();


    in = 7'b0000000; // all zeros, should be valid
    #10 show();

    in = 7'b1101101; // data = 1011 
    #10 show();

    $finish;
end

endmodule