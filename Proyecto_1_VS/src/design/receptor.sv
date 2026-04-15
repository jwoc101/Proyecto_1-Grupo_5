module receptor (
    input  wire [6:0] in,      // 7-bit entrada (switches/jumpers)
    output wire [3:0] led,    // LEDs (datos corregidos)
    output wire [6:0] seg7,
    output wire [3:0] palabra, 
    output wire [2:0] err    // display 7 segmentos
);

// -------- señales internas --------
//wire [6:0] in = ~in_ext;  // palabra recibida (puede ser in_ext o una versión corregida)
wire [2:0] syn;
wire [3:0] data_corr;

// -------- DECODIFICADOR --------
decodificador dec (
    .in(in),
    .err(syn)
);

// -------- CORRECTOR --------
corrector cor (
    .in(in),
    .syn(syn),
    .data(data_corr)
);

// -------- LED DISPLAY --------
led_display led_disp (
    .data(data_corr),
    .led(led)
);

// -------- 7-SEG DISPLAY --------
seg7_display seg_disp (
    .data(data_corr),
    .seg7(seg7)
);

// -------- salida de error --------
assign err = syn;
assign palabra = data_corr;

endmodule