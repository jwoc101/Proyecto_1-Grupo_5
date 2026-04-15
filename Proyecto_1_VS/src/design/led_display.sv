// =============================================================================
// Módulo: led_display
// Descripción: Despliega la palabra corregida de 4 bits en los LEDs de la FPGA.
//              Los LEDs de la TangNano son activos en BAJO (1 = apagado).
// Entradas:
//   data [3:0] - Palabra corregida proveniente del módulo corrector
// Salidas:
//   leds [3:0] - Conexión directa a los 4 LEDs de la FPGA
// =============================================================================

module led_display (
    input  wire [3:0] data,   // Palabra corregida (d4 d3 d2 d1)
    output wire [3:0] led    // LEDs de la FPGA (activo en BAJO)
);

    // Asignación directa: cada bit de data enciende su LED correspondiente
    assign led = ~data;

endmodule
