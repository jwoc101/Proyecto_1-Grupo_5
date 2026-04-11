module corrector (
    input  wire [6:0] in,      
    input  wire [2:0] err,     
    output wire [3:0] data     
);

//data corregida para uso interno
wire [6:0] corr;

// err se interpreta como un sindrome que se pueda usar internamente
// 111 = no hay error → se vuelve 000
wire [2:0] syn;
//assign syn = (err == 3'b111) ? 3'b000 : err;
assign syn = err; // el receptor ya se encarga de convertir 111 a 000, así que aquí se asigna directamente

// Cambia el bit indicado por el sindrome

assign corr[0] = (syn == 3'b001) ? ~in[0] : in[0];
assign corr[1] = (syn == 3'b010) ? ~in[1] : in[1];
assign corr[2] = (syn == 3'b011) ? ~in[2] : in[2];
assign corr[3] = (syn == 3'b100) ? ~in[3] : in[3];
assign corr[4] = (syn == 3'b101) ? ~in[4] : in[4];
assign corr[5] = (syn == 3'b110) ? ~in[5] : in[5];
assign corr[6] = (syn == 3'b111) ? ~in[6] : in[6];

// Se asignan los bits relevantes del mensaje corregido
assign data[0] = corr[2]; // d1
assign data[1] = corr[4]; // d2
assign data[2] = corr[5]; // d3
assign data[3] = corr[6]; // d4

endmodule