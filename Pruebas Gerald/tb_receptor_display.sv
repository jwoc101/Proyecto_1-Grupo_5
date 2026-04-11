`timescale 1ns/1ps

module tb_receptor_display;

    // Senales seg7_display
    reg  [3:0] seg7_data;
    wire [6:0] seg7_out;

    seg7_display uut_seg7 (
        .data(seg7_data),
        .seg7(seg7_out)
    );

    // Senales led_display
    reg  [3:0] led_data;
    wire [3:0] led_out;

    led_display uut_led (
        .data(led_data),
        .leds(led_out)
    );

    // Senales selector
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

    // Senales integracion con receptor
    reg  [6:0] rx_in;
    wire [6:0] rx_raw;
    wire [2:0] rx_err;
    wire [3:0] rx_data;

    receptor uut_rx (
        .in(rx_in),
        .raw(rx_raw),
        .err(rx_err),
        .data(rx_data)
    );

    wire [3:0] int_led_out;
    wire [6:0] int_seg7_out;
    wire [3:0] int_sel_out;
    reg        int_sel_sw;

    led_display uut_int_led (
        .data(rx_data),
        .leds(int_led_out)
    );

    seg7_display uut_int_seg7 (
        .data(int_sel_out),
        .seg7(int_seg7_out)
    );

    selector uut_int_sel (
        .data(rx_data),
        .err_pos(rx_err),
        .sel(int_sel_sw),
        .out(int_sel_out)
    );

    integer test_errors = 0;
    integer test_count  = 0;

    // Tarea: verificar seg7
    task check_seg7;
        input [3:0] valor;
        input [6:0] esperado;
        begin
            seg7_data = valor;
            #10;
            test_count = test_count + 1;
            if (seg7_out !== esperado) begin
                $display("ERROR [seg7] valor=%0h seg7=%b esperado=%b", valor, seg7_out, esperado);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [seg7] valor=%0h seg7=%b", valor, seg7_out);
            end
        end
    endtask

    // Tarea: verificar led
    task check_led;
        input [3:0] valor;
        begin
            led_data = valor;
            #10;
            test_count = test_count + 1;
            if (led_out !== valor) begin
                $display("ERROR [led] data=%b leds=%b esperado=%b", valor, led_out, valor);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [led] data=%b leds=%b", valor, led_out);
            end
        end
    endtask

    // Tarea: verificar selector
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
                $display("ERROR [sel] data=%b err=%b sel=%b out=%b esperado=%b", dato, err, sw, sel_out, esperado);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [sel] data=%b err=%b sel=%b out=%b", dato, err, sw, sel_out);
            end
        end
    endtask

    // Funcion: codificacion Hamming (7,4)
    // Posicion: 1  2  3  4  5  6  7
    // Bit:      p1 p2 d1 p3 d2 d3 d4
    // Indice:  [0][1][2][3][4][5][6]
    function [6:0] hamming_encode;
        input [3:0] data;
        reg d1, d2, d3, d4;
        reg p1, p2, p3;
        begin
            d1 = data[0];
            d2 = data[1];
            d3 = data[2];
            d4 = data[3];
            p1 = d1 ^ d2 ^ d4;
            p2 = d1 ^ d3 ^ d4;
            p3 = d2 ^ d3 ^ d4;
            hamming_encode = {d4, d3, d2, p3, d1, p2, p1};
        end
    endfunction

    // Tarea: integracion completa
    task check_integracion;
        input [3:0] dato_original;
        input [2:0] pos_error;
        input       modo_sel;
        reg [6:0] codificado;
        reg [6:0] con_error;
        reg [3:0] esperado_data;
        integer   bit_pos;
        begin
            codificado = hamming_encode(dato_original);
            if (pos_error == 3'b000) begin
                con_error = codificado;
            end else begin
                bit_pos = pos_error - 1;
                con_error = codificado;
                con_error[bit_pos] = ~codificado[bit_pos];
            end
            esperado_data = dato_original;
            rx_in      = con_error;
            int_sel_sw = modo_sel;
            #20;
            test_count = test_count + 1;
            if (rx_data !== esperado_data) begin
                $display("ERROR [integ] dato=%b pos=%0d rx_data=%b esperado=%b cod=%b err=%b sin=%b",
                          dato_original, pos_error, rx_data, esperado_data, codificado, con_error, rx_err);
                test_errors = test_errors + 1;
            end else begin
                $display("OK    [integ] dato=%b pos=%0d rx_data=%b sindrome=%b sel_out=%b sel=%b",
                          dato_original, pos_error, rx_data, rx_err, int_sel_out, modo_sel);
            end
            test_count = test_count + 1;
            if (int_led_out !== rx_data) begin
                $display("ERROR [integ-led] leds=%b esperado=%b", int_led_out, rx_data);
                test_errors = test_errors + 1;
            end
            if (modo_sel == 1'b0) begin
                test_count = test_count + 1;
                if (int_sel_out !== rx_data) begin
                    $display("ERROR [integ-sel-OFF] sel_out=%b esperado=%b", int_sel_out, rx_data);
                    test_errors = test_errors + 1;
                end
            end else begin
                test_count = test_count + 1;
                if (int_sel_out !== {1'b0, rx_err}) begin
                    $display("ERROR [integ-sel-ON] sel_out=%b esperado=%b", int_sel_out, {1'b0, rx_err});
                    test_errors = test_errors + 1;
                end
            end
        end
    endtask

    // Bloque principal
    initial begin
        $dumpfile("ondas.vcd");
        $dumpvars(0, tb_receptor_display);

        $display("==============================================");
        $display("TESTBENCH: receptor display LED selector");
        $display("==============================================");

        // SECCION 1: seg7_display - 16 valores hex
        $display("\n--- SECCION 1: seg7_display ---");
        check_seg7(4'h0, 7'b1000000);
        check_seg7(4'h1, 7'b1111001);
        check_seg7(4'h2, 7'b0100100);
        check_seg7(4'h3, 7'b0110000);
        check_seg7(4'h4, 7'b0011001);
        check_seg7(4'h5, 7'b0010010);
        check_seg7(4'h6, 7'b0000010);
        check_seg7(4'h7, 7'b1111000);
        check_seg7(4'h8, 7'b0000000);
        check_seg7(4'h9, 7'b0010000);
        check_seg7(4'hA, 7'b0001000);
        check_seg7(4'hB, 7'b0000011);
        check_seg7(4'hC, 7'b1000110);
        check_seg7(4'hD, 7'b0100001);
        check_seg7(4'hE, 7'b0000110);
        check_seg7(4'hF, 7'b0001110);

        // SECCION 2: led_display - 16 valores
        $display("\n--- SECCION 2: led_display ---");
        begin : led_loop
            integer i;
            for (i = 0; i < 16; i = i + 1)
                check_led(i[3:0]);
        end

        // SECCION 3: selector
        $display("\n--- SECCION 3: selector ---");
        check_selector(4'b1010, 3'b011, 1'b0, 4'b1010);
        check_selector(4'b0001, 3'b101, 1'b0, 4'b0001);
        check_selector(4'b1111, 3'b111, 1'b0, 4'b1111);
        check_selector(4'b0000, 3'b000, 1'b0, 4'b0000);
        check_selector(4'b1010, 3'b011, 1'b1, 4'b0011);
        check_selector(4'b0001, 3'b101, 1'b1, 4'b0101);
        check_selector(4'b1111, 3'b111, 1'b1, 4'b0111);
        check_selector(4'b0000, 3'b000, 1'b1, 4'b0000);
        check_selector(4'b1100, 3'b001, 1'b1, 4'b0001);
        check_selector(4'b1100, 3'b010, 1'b1, 4'b0010);
        check_selector(4'b1100, 3'b100, 1'b1, 4'b0100);
        check_selector(4'b1100, 3'b110, 1'b1, 4'b0110);
        sel_data = 4'b1011; sel_err = 3'b010; sel_sw = 1'b0; #10;
        $display("CHECK [sel cambio] sel=0 out=%b (esperado 1011)", sel_out);
        sel_sw = 1'b1; #10;
        $display("CHECK [sel cambio] sel=1 out=%b (esperado 0010)", sel_out);

        // SECCION 4: integracion completa
        $display("\n--- SECCION 4: Integracion completa ---");
        begin : integ_loop
            integer dato;
            integer pos;
            for (dato = 0; dato < 16; dato = dato + 1) begin
                check_integracion(dato[3:0], 3'b000, 1'b0);
                for (pos = 1; pos <= 7; pos = pos + 1) begin
                    check_integracion(dato[3:0], pos[2:0], 1'b0);
                    check_integracion(dato[3:0], pos[2:0], 1'b1);
                end
            end
        end

        // SECCION 5: casos especiales
        $display("\n--- SECCION 5: Casos especiales ---");
        rx_in = hamming_encode(4'b1001); int_sel_sw = 1'b0; #20;
        $display("CHECK [sin error] rx_data=%b sindrome=%b sel_out=%b", rx_data, rx_err, int_sel_out);
        check_integracion(4'b0000, 3'b000, 1'b0);
        check_integracion(4'b1111, 3'b000, 1'b0);

        // Resumen
        $display("\n==============================================");
        $display("RESULTADO: %0d pruebas, %0d errores", test_count, test_errors);
        if (test_errors == 0)
            $display("TODOS LOS MODULOS FUNCIONAN CORRECTAMENTE");
        else
            $display("SE ENCONTRARON ERRORES - revisar mensajes");
        $display("==============================================");

        $finish;
    end

endmodule
