module decodificador (
    input  wire [6:0] in,     // palabra recibida
    output wire [2:0] err     // síndrome (000 = no error)
);

// Parity checks (Hamming)
assign err[0] = in[0] ^ in[2] ^ in[4] ^ in[6]; // p1
assign err[1] = in[1] ^ in[2] ^ in[5] ^ in[6]; // p2
assign err[2] = in[3] ^ in[4] ^ in[5] ^ in[6]; // p3

endmodule