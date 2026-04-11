// =============================================================================
// Módulo: selector
// Descripción: Selecciona entre la palabra corregida (4 bits) o la posición
//              del bit con error (síndrome, 3 bits → extendido a 4 bits)
//              según un switch de control. Este módulo representa la lógica
//              que se alambra en la protoboard pero se describe aquí en HDL
//              para simulación y síntesis.
//
// Entradas:
//   data    [3:0] - Palabra corregida proveniente del módulo corrector
//   err_pos [2:0] - Posición del bit con error (síndrome) del decodificador
//   sel          - Switch de control:
//                    0 (OFF) → salida = palabra corregida
//                    1 (ON)  → salida = posición del bit con error
// Salidas:
//   out     [3:0] - 4 bits seleccionados hacia la FPGA (para seg7 y LEDs)
//
// Nota: err_pos es de 3 bits. Se extiende a 4 bits fijando el MSB a 0,
//       ya que el cuarto bit no es determinante para ningún circuito
//       (según especificación del proyecto, sección 7.5).
// =============================================================================

module selector (
    input  wire [3:0] data,      // Palabra corregida (4 bits)
    input  wire [2:0] err_pos,   // Posición del bit con error / síndrome (3 bits)
    input  wire       sel,       // 0 = mostrar dato corregido, 1 = mostrar posición error
    output wire [3:0] out        // Salida seleccionada (4 bits)
);

    // Extensión del síndrome de 3 a 4 bits: MSB fijo en 0
    wire [3:0] err_pos_ext;
    assign err_pos_ext = {1'b0, err_pos};

    // Multiplexor 2:1 de 4 bits
    // sel = 0 → out = data (palabra corregida)
    // sel = 1 → out = err_pos_ext (posición del error, extendida)
    assign out = sel ? err_pos_ext : data;

endmodule
