//los pines de entrada seran del 79 al 85
module decodificador (
    input  wire [6:0] in,     
    output wire [6:0] data,   
    output wire [2:0] err     
);

// input se asigna directamente a data
assign data = in;

// Sindrome (3 bits que indican error)
wire s0, s1, s2;

// se revisa paridad XOR
assign s0 = in[0] ^ in[2] ^ in[4] ^ in[6]; // p1 check
assign s1 = in[1] ^ in[2] ^ in[5] ^ in[6]; // p2 check
assign s2 = in[3] ^ in[4] ^ in[5] ^ in[6]; // p3 check

// crear sindrome para uso interno
wire [2:0] syn;
assign err = {s2, s1, s0};

//assign err = syn;
// Output:
// If no hay error → 111
// Else → syndrome
//assign err = (syn == 3'b000) ? 3'b111 : syn;

endmodule