module corrector (
    input  wire [6:0] in,     // palabra recibida
    input  wire [2:0] syn,    // síndrome
    output wire [3:0] data    // datos corregidos
);

// -------- corrección --------
wire [6:0] corr;

assign corr[0] = (syn == 3'b001) ? ~in[0] : in[0];
assign corr[1] = (syn == 3'b010) ? ~in[1] : in[1];
assign corr[2] = (syn == 3'b011) ? ~in[2] : in[2];
assign corr[3] = (syn == 3'b100) ? ~in[3] : in[3];
assign corr[4] = (syn == 3'b101) ? ~in[4] : in[4];
assign corr[5] = (syn == 3'b110) ? ~in[5] : in[5];
assign corr[6] = (syn == 3'b111) ? ~in[6] : in[6];

// -------- extracción de datos --------
// posiciones: d1=3, d2=5, d3=6, d4=7

assign data[0] = corr[2]; // d1
assign data[1] = corr[4]; // d2
assign data[2] = corr[5]; // d3
assign data[3] = corr[6]; // d4

endmodule