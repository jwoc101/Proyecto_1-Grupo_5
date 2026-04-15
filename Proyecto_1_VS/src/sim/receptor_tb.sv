`timescale 1ns/1ps

module receptor_tb;

reg  [6:0] in;
wire [3:0] led;
wire [6:0] seg7;
wire [3:0] palabra;
wire [2:0] err;

// Instantiate your receptor module
receptor uut (
    .in(in),
    .led(led),
    .seg7(seg7),
    .palabra(palabra),
    .err(err)
);

// Helper task
task show;
    begin
        $display("in=%b | err=%b | palabra=%b | led=%b | seg7=%b",
                  in, err, palabra, led, seg7);
    end
endtask;

integer i;

initial begin
    $dumpfile("receptor_tb.vcd");
    $dumpvars(0, receptor_tb);

    // -----------------------------
    // Test 1: No error
    in = 7'b0000000;
    #10 show();

    // -----------------------------
    // Test 2: Single-bit errors
    for (i = 0; i < 7; i = i + 1) begin
        in = 7'b0000000 ^ (7'b0000001 << i);
        #10 show();
    end

    // -----------------------------
    // Test 3: Random value
    in = 7'b1011010;
    #10 show();

    // -----------------------------
    // Test 4: All ones
    in = 7'b1111111;
    #10 show();


    in = 7'b1101101;
    #10 show();

    $finish;
end

endmodule