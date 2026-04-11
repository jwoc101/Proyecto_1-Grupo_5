// =============================================================================
// Módulo: seg7_display
// Descripción: Codifica 4 bits binarios para mostrarlos en un display de
//              7 segmentos en formato hexadecimal (0-F).
//              Display de ÁNODO COMÚN → segmento encendido con '0' (activo bajo).
//
// Distribución de segmentos en seg7[6:0]:
//        seg7[6] = g (segmento central)
//        seg7[5] = f (segmento superior izquierdo)
//        seg7[4] = e (segmento inferior izquierdo)
//        seg7[3] = d (segmento inferior)
//        seg7[2] = c (segmento inferior derecho)
//        seg7[1] = b (segmento superior derecho)
//        seg7[0] = a (segmento superior)
//
//        --a--
//       f     b
//        --g--
//       e     c
//        --d--
//
// Entradas:
//   data [3:0] - Palabra corregida en binario (valor 0 a 15)
// Salidas:
//   seg7 [6:0] - Señales a los 7 segmentos (activo bajo para ánodo común)
// =============================================================================

module seg7_display (
    input  wire [3:0] data,   // Palabra de 4 bits a mostrar (0–15)
    output reg  [6:0] seg7    // {g, f, e, d, c, b, a} — activo bajo
);

    // Tabla de verdad para display ánodo común (0 = segmento encendido)
    //                      gfedcba
    always @(*) begin
        case (data)
            4'h0: seg7 = 7'b1000000; // 0
            4'h1: seg7 = 7'b1111001; // 1
            4'h2: seg7 = 7'b0100100; // 2
            4'h3: seg7 = 7'b0110000; // 3
            4'h4: seg7 = 7'b0011001; // 4
            4'h5: seg7 = 7'b0010010; // 5
            4'h6: seg7 = 7'b0000010; // 6
            4'h7: seg7 = 7'b1111000; // 7
            4'h8: seg7 = 7'b0000000; // 8
            4'h9: seg7 = 7'b0010000; // 9
            4'hA: seg7 = 7'b0001000; // A
            4'hB: seg7 = 7'b0000011; // b
            4'hC: seg7 = 7'b1000110; // C
            4'hD: seg7 = 7'b0100001; // d
            4'hE: seg7 = 7'b0000110; // E
            4'hF: seg7 = 7'b0001110; // F
            default: seg7 = 7'b1111111; // Apagado
        endcase
    end

endmodule
