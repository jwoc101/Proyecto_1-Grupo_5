# Diseño Digital Combinacional en Dispositivos Programables

## Introducción

[Start with a hook — interesting fact, question, or quote]
[Provide background context on the topic]
[End with a clear **thesis statement** that outlines your main argument]


## Descripción de los Módulos

### Módulo Decodificador: `decodificador.sv`

```SystemVerilog
module decodificador (
    input  wire [6:0] in,     // palabra recibida
    output wire [2:0] err     // síndrome (000 = no error)
);

// Parity checks (Hamming)
assign err[0] = in[0] ^ in[2] ^ in[4] ^ in[6]; // p1
assign err[1] = in[1] ^ in[2] ^ in[5] ^ in[6]; // p2
assign err[2] = in[3] ^ in[4] ^ in[5] ^ in[6]; // p3

endmodule
```

#### Entradas

`in[6:0]`: Palabra de 7 bits recibida directamente del transmisor

#### Salidas

`err[2:0]`: Vector de 3 bits correspondiente a la posición del error en binario

#### Comportamiento

Se recibe una entrada de 7 bits mediante 7 pines asignados en la FPGA. Se asume que esta entrada contiene 4 bits correspondientes al mensaje que se desea transmitir, y 3 bits correspondientes a los bits de paridad. Estos bits de paridad, también se asume, están en la primera, segunda y cuarta posición del mensaje; posiciones correspondientes a potencias de 2. El mensaje de entrada solo puede tener como máximo un error.

Se realizan pruebas de paridad en tres grupos de cuatro bits cada uno. Cada bit de paridad solo pertenece a uno de estos grupos. La salida consiste en un vector de 3 bits que señala en binario la posición donde se encontró el error en la entrada. En caso de no encontrar un error, la salida sería un vector nulo de 3 bits. 

### Módulo Corrector: `corrector.sv`
```SystemVerilog
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
```

#### Entradas

#### Salidas
#### Comportamiento
### Módulo de Despliegue de LEDs
#### Entradas
#### Salidas
#### Comportamiento
### Módulo para Display de 7 Segmentos
#### Entradas
#### Salidas
#### Comportamiento
### Módulo Selector
#### Entradas
#### Salidas
#### Comportamiento




## Consumo de recursos
![Consumo de recursos](Imágenes/Consumo.jpeg)

**Topic sentence:** [State second supporting point]

- Evidence / example:
- Explanation of evidence:
- Link back to thesis:

## Body Paragraph 3 — Third Main Point (optional)

**Topic sentence:** [State third supporting point]

- Evidence / example:
- Explanation of evidence:
- Link back to thesis:

## Counterargument & Rebuttal (optional)

**Acknowledge opposing view:** [Some might argue that...]

**Rebuttal:** [However, this overlooks... because...]

## Conclusion

- Restate thesis (in different words)
- Summarize main points
- End with a broader thought, call to action, or closing insight

---

## References (if needed)

- Author, A. (Year). *Title*. Publisher.
- Website, URL
