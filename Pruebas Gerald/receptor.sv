module receptor (
    input  wire [6:0] in,       
    output wire [6:0] raw,      
    output wire [2:0] err,      
    output wire [3:0] data      
);

// sindrome interno
wire [2:0] syn;

// Instanciar decodificador
decodificador dec (
    .in(in),
    .data(raw),
    .err(syn)
);

// Instanciar corrector
corrector cor (
    .in(in),
    .err(syn),
    .data(data)
);

// Output sindrome
assign err = syn;

endmodule