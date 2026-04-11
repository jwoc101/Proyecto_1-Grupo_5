// =============================================================================
// Testbench: tb_receptor_display
// Descripción: Testbench exhaustivo para verificar los módulos:
//              - led_display
//              - seg7_display
//              - selector
//              Integrados con los módulos del compañero:
//              - decodificador
//              - corrector
//              - receptor
//
// Casos de prueba:
//   1. Verificación completa de seg7_display para los 16 valores hexadecimales
//   2. Verificación del selector en ambos modos (dato / síndrome)
//   3. Verificación de led_display para los 16 valores posibles
//   4. Integración completa: palabra transmitida → receptor → display
//      con y sin error en cada posición de bit (1–7)
//   5. Caso especial: síndrome 000 (sin error)
// =============================================================================

`timescale 1ns/1ps

module tb_receptor_display;

    // -------------------------------------------------------------------------
    // Señales para pruebas individuales de seg7_display
    // -------------------------------------------------------------------------
    reg  [3:0] seg7_data;
    wire [6:0] seg7_out;

    seg7_display uut_seg7 (
        .data(seg7_data),
        .seg7(seg7_out)
    );

    // -------------------------------------------------------------------------
    // Señales para pruebas individuales de led_display
    // -------------------------------------------------------------------------
    reg  [3:0] led_data;
    wire [3:0] led_out;

    led_display uut_led (
        .data(led_data),
        .leds(led_out)
    );

    // -------------------------------------------------------------------------
    // Señales para pruebas individuales de selector
    // -------------------------------------------------------------------------
    reg  [3:0] sel_data;
    reg  [2:0] sel_err;
    reg        sel_sw;
    wire [3:0] sel_out;

    selector uut_sel (
        .data(sel_data),
        .err_pos(sel_err),
        .sel(sel_sw),
        .out(sel_out)
    );

    // -------------------------------------------------------------------------
    // Señales para prueba de integración completa con receptor
    // -------------------------------------------------------------------------
    reg  [6:0] rx_in;          // Palabra de 7 bits recibida (posiblemente con error)
    wire [6:0] rx_raw;         // Palabra recibida sin modificar
    wire [2:0] rx_err;         // Síndrome del decodificador
    wire [3:0] rx_data;        // Datos corregidos

    receptor uut_rx (
        .in(rx_in),
        .raw(rx_raw),
        .err(rx_err),
        .data(rx_data)
    );

    // Display integrado con receptor
    wire [3:0] int_led_out;
    wire [6:0] int_seg7_out;
    wire [3:0] int_sel_out;

    reg        int_sel_sw;

    led_display uut_int_led (
        .data(rx_data),
        .leds(int_led_out)
    );

    seg7_display uut_int_seg7 (
        .data(int_sel_out),    // recibe lo que el selector decida mostrar
        .seg7(int_seg7_out)
    );

    selector uut_int_sel (
        .data(rx_data),
        .err_pos(rx_err),
        .sel(int_sel_sw),
        .out(int_sel_out)
    );

    // -------------------------------------------------------------------------
    // Contador de errores de prueba
    // -------------------------------------------------------------------------
    integer test_errors = 0;
    integer test_count  = 0;

    // -------------------------------------------------------------------------
    // Tarea auxiliar: verificar seg7_display
    // Compara la salida con el valor esperado e imprime resultado
    // -------------------------------------------------------------------------
    task check_seg7;
        input [3:0] valor;
        input [6:0] esperado;
        input [63:0] nombre; // no se usa en comparación, solo referencia
        begin
            seg7_data = valor;
            #10;
            test_count = test_count + 1;
            if (seg7_out !== esperado) begin
                $display("ERROR [seg7] valor=%0h → seg7=%b, esperado=%b",
                          valor, seg7_out, esperado);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [seg7] valor=%0h → seg7=%b (gfedcba)", valor, seg7_out);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Tarea auxiliar: verificar led_display
    // -------------------------------------------------------------------------
    task check_led;
        input [3:0] valor;
        begin
            led_data = valor;
            #10;
            test_count = test_count + 1;
            if (led_out !== valor) begin
                $display("ERROR [led] data=%b → leds=%b, esperado=%b",
                          valor, led_out, valor);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [led] data=%b → leds=%b", valor, led_out);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Tarea auxiliar: verificar selector
    // -------------------------------------------------------------------------
    task check_selector;
        input [3:0] dato;
        input [2:0] err;
        input       sw;
        input [3:0] esperado;
        begin
            sel_data = dato;
            sel_err  = err;
            sel_sw   = sw;
            #10;
            test_count = test_count + 1;
            if (sel_out !== esperado) begin
                $display("ERROR [sel] data=%b err=%b sel=%b → out=%b, esperado=%b",
                          dato, err, sw, sel_out, esperado);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [sel] data=%b err=%b sel=%b → out=%b", dato, err, sw, sel_out);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Función: codificación Hamming (7,4) — replica la lógica del transmisor
    // para generar palabras de prueba válidas
    // Distribución de bits según libro de texto:
    //   Posición: 1  2  3  4  5  6  7
    //   Bit:      p1 p2 d1 p3 d2 d3 d4
    //   Índice:  [0][1][2][3][4][5][6]
    // -------------------------------------------------------------------------
    function [6:0] hamming_encode;
        input [3:0] data; // d1 d2 d3 d4
        reg d1, d2, d3, d4;
        reg p1, p2, p3;
        begin
            d1 = data[0];
            d2 = data[1];
            d3 = data[2];
            d4 = data[3];
            // Paridad par
            p1 = d1 ^ d2 ^ d4;      // posiciones 1,3,5,7 → p1,d1,d2,d4
            p2 = d1 ^ d3 ^ d4;      // posiciones 2,3,6,7 → p2,d1,d3,d4
            p3 = d2 ^ d3 ^ d4;      // posiciones 4,5,6,7 → p3,d2,d3,d4
            hamming_encode = {d4, d3, d2, p3, d1, p2, p1};
            //                [6] [5] [4] [3] [2] [1] [0]
        end
    endfunction

    // -------------------------------------------------------------------------
    // Tarea: prueba de integración completa
    // Codifica una palabra, opcionalmente introduce un error en una posición,
    // la pasa al receptor y verifica que el dato corregido sea correcto.
    // -------------------------------------------------------------------------
    task check_integracion;
        input [3:0] dato_original;   // Palabra de 4 bits original
        input [2:0] pos_error;       // Posición del error (1–7), 0 = sin error
        input        modo_sel;       // 0 = mostrar dato, 1 = mostrar síndrome
        
        reg [6:0] codificado;
        reg [6:0] con_error;
        reg [3:0] esperado_data;
        reg [3:0] esperado_sel_dato;
        reg [3:0] esperado_sel_err;
        integer   bit_pos;
        
        begin
            codificado = hamming_encode(dato_original);
            
            // Introducir error si pos_error != 0
            if (pos_error == 3'b000) begin
                con_error = codificado;
            end else begin
                bit_pos = pos_error - 1; // convertir posición 1-based a índice 0-based
                con_error = codificado;
                con_error[bit_pos] = ~codificado[bit_pos];
            end
            
            // El dato esperado al recuperar siempre es el original
            esperado_data = dato_original;
            
            // Configurar integración
            rx_in      = con_error;
            int_sel_sw = modo_sel;
            #20;
            
            test_count = test_count + 1;
            
            // Verificar datos corregidos
            if (rx_data !== esperado_data) begin
                $display("ERROR [integ] dato=%b pos_err=%0d → rx_data=%b, esperado=%b | codificado=%b con_error=%b sindrome=%b",
                          dato_original, pos_error, rx_data, esperado_data, codificado, con_error, rx_err);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [integ] dato=%b pos_err=%0d → rx_data=%b sindrome=%b sel_out=%b (sel=%b)",
                          dato_original, pos_error, rx_data, rx_err, int_sel_out, modo_sel);
            end
            
            // Verificar que LEDs coincidan con datos corregidos
            test_count = test_count + 1;
            if (int_led_out !== rx_data) begin
                $display("ERROR [integ-led] leds=%b, esperado=%b", int_led_out, rx_data);
                test_errors = test_errors + 1;
            end
            
            // Verificar selector
            if (modo_sel == 1'b0) begin
                // Selector OFF → debe mostrar dato corregido
                test_count = test_count + 1;
                if (int_sel_out !== rx_data) begin
                    $display("ERROR [integ-sel OFF] sel_out=%b, esperado data=%b", int_sel_out, rx_data);
                    test_errors = test_errors + 1;
                end
            end else begin
                // Selector ON → debe mostrar síndrome extendido a 4 bits (MSB=0)
                test_count = test_count + 1;
                if (int_sel_out !== {1'b0, rx_err}) begin
                    $display("ERROR [integ-sel ON] sel_out=%b, esperado err_ext=%b", int_sel_out, {1'b0, rx_err});
                    test_errors = test_errors + 1;
                end
            end
        end
    endtask

    // =========================================================================
    // Bloque principal de pruebas
    // =========================================================================
    initial begin
        $display("=============================================================");
        $display("  TESTBENCH: Módulos display, LED y selector del receptor");
        $display("=============================================================");

        // ------------------------------------------------------------------
        // SECCIÓN 1: Verificación exhaustiva de seg7_display (los 16 valores)
        // ------------------------------------------------------------------
        $display("\n--- SECCIÓN 1: seg7_display (ánodo común, activo bajo) ---");
        //                         gfedcba
        check_seg7(4'h0, 7'b1000000, "0");
        check_seg7(4'h1, 7'b1111001, "1");
        check_seg7(4'h2, 7'b0100100, "2");
        check_seg7(4'h3, 7'b0110000, "3");
        check_seg7(4'h4, 7'b0011001, "4");
        check_seg7(4'h5, 7'b0010010, "5");
        check_seg7(4'h6, 7'b0000010, "6");
        check_seg7(4'h7, 7'b1111000, "7");
        check_seg7(4'h8, 7'b0000000, "8");
        check_seg7(4'h9, 7'b0010000, "9");
        check_seg7(4'hA, 7'b0001000, "A");
        check_seg7(4'hB, 7'b0000011, "b");
        check_seg7(4'hC, 7'b1000110, "C");
        check_seg7(4'hD, 7'b0100001, "d");
        check_seg7(4'hE, 7'b0000110, "E");
        check_seg7(4'hF, 7'b0001110, "F");

        // ------------------------------------------------------------------
        // SECCIÓN 2: Verificación exhaustiva de led_display (16 valores)
        // ------------------------------------------------------------------
        $display("\n--- SECCIÓN 2: led_display ---");
        begin : led_loop
            integer i;
            for (i = 0; i < 16; i = i + 1) begin
                check_led(i[3:0]);
            end
        end

        // ------------------------------------------------------------------
        // SECCIÓN 3: Verificación del selector
        // ------------------------------------------------------------------
        $display("\n--- SECCIÓN 3: selector ---");

        // sel=0 → debe pasar dato corregido
        check_selector(4'b1010, 3'b011, 1'b0, 4'b1010); // dato=1010, ignorar err
        check_selector(4'b0001, 3'b101, 1'b0, 4'b0001);
        check_selector(4'b1111, 3'b111, 1'b0, 4'b1111);
        check_selector(4'b0000, 3'b000, 1'b0, 4'b0000);

        // sel=1 → debe pasar síndrome extendido {0, err[2:0]}
        check_selector(4'b1010, 3'b011, 1'b1, 4'b0011); // {0,011} = 0011
        check_selector(4'b0001, 3'b101, 1'b1, 4'b0101); // {0,101} = 0101
        check_selector(4'b1111, 3'b111, 1'b1, 4'b0111); // {0,111} = 0111
        check_selector(4'b0000, 3'b000, 1'b1, 4'b0000); // {0,000} = 0000
        check_selector(4'b1100, 3'b001, 1'b1, 4'b0001); // {0,001} = 0001
        check_selector(4'b1100, 3'b010, 1'b1, 4'b0010); // {0,010} = 0010
        check_selector(4'b1100, 3'b100, 1'b1, 4'b0100); // {0,100} = 0100
        check_selector(4'b1100, 3'b110, 1'b1, 4'b0110); // {0,110} = 0110

        // Cambio dinámico de sel sin cambiar entradas
        sel_data = 4'b1011; sel_err = 3'b010; sel_sw = 1'b0; #10;
        $display("CHECK [sel cambio] sel=0 out=%b (esperado 1011)", sel_out);
        sel_sw = 1'b1; #10;
        $display("CHECK [sel cambio] sel=1 out=%b (esperado 0010)", sel_out);

        // ------------------------------------------------------------------
        // SECCIÓN 4: Integración completa con receptor
        // Prueba todas las palabras de 4 bits con error en cada posición
        // ------------------------------------------------------------------
        $display("\n--- SECCIÓN 4: Integración completa (receptor + display) ---");
        $display("    Formato: dato=XXXX pos_err=N → rx_data=XXXX sindrome=XXX");

        begin : integ_loop
            integer dato;
            integer pos;
            for (dato = 0; dato < 16; dato = dato + 1) begin
                // Sin error
                check_integracion(dato[3:0], 3'b000, 1'b0);
                // Error en cada posición de bit (1 a 7)
                for (pos = 1; pos <= 7; pos = pos + 1) begin
                    check_integracion(dato[3:0], pos[2:0], 1'b0);
                    check_integracion(dato[3:0], pos[2:0], 1'b1);
                end
            end
        end

        // ------------------------------------------------------------------
        // SECCIÓN 5: Casos especiales
        // ------------------------------------------------------------------
        $display("\n--- SECCIÓN 5: Casos especiales ---");

        // Síndrome 000 → sin error, selector OFF muestra dato
        rx_in = hamming_encode(4'b1001); int_sel_sw = 1'b0; #20;
        $display("CHECK [especial sin_error] rx_data=%b sindrome=%b sel_out=%b",
                  rx_data, rx_err, int_sel_out);

        // Todos los bits de la palabra en 0
        check_integracion(4'b0000, 3'b000, 1'b0);
        // Todos los bits de la palabra en 1
        check_integracion(4'b1111, 3'b000, 1'b0);

        // ------------------------------------------------------------------
        // Resumen final
        // ------------------------------------------------------------------
        $display("\n=============================================================");
        $display("  RESULTADO: %0d pruebas ejecutadas, %0d errores encontrados",
                  test_count, test_errors);
        if (test_errors == 0)
            $display("  ✓ TODOS LOS MÓDULOS FUNCIONAN CORRECTAMENTE");
        else
            $display("  ✗ SE ENCONTRARON ERRORES — revisar los mensajes anteriores");
        $display("=============================================================");

        $finish;
    end

endmodule
