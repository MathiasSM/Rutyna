---
zip: https://github.com/MathiasSM/Rutyna/releases/download/v1.0/Rutyna.zip
tar: https://github.com/MathiasSM/Rutyna/releases/download/v1.0/Rutyna.tar
---
# Interpretador Rutyna

Se trata de un interpretador sencillo implementado en Ruby para el lenguaje inventado "Retina". Fue realizado como parte del curso CI3725 (Traductores e Interpretadores) de la **Universidad Simón Bolívar** por _MathiasSM_ y _CSerradaG_.

+ [Más sobre Retina](#retina)
+ [Más sobre Rutyna](#rutyna)


## Retina

_Tomado (y ligeramente modificado) de la [Especificación del Lenguaje Retina] del Profesor Lilue._

Lenguaje de programación inspirado en [Logo], junto al concepto de *[turtle graphics]*, para la generación de imágenes en formato [pbm]. La extensión de los archivos de Retina es `.rtn`.

### Ejemplo de un programa en Retina

A continuación un ejemplo de un programa en Retina que dibuja un cuadrado, donde cada arista mide 50px.
```
program
    with
        number x = 4;
    do
        repeat x times
            forward(50); # Traza una línea por 50 puntos
            rotatel(90); # Gira 90 grados contra-reloj
        end;
    end;
end;
```

*****

### Estructura lexicográfica

En Retina, cualquier _whitespace_ (espacios, saltos de líneas, tabulaciones) separan lexemas. Los whitespaces son ignorados junto a los comentarios. Para los mismos, se coloca un `#`, y los caracteres a partir de allí y hasta el próximo salto de línea sern considerados whitespace. Este comportamiento de comentarios no sucede si el `#` se encuentra dentro de un _string_.

*****

### Manejo de datos

#### Tipos de datos

+ **Boolean.** Las expresiones `true` y `false` pertenecen al tipo `boolean`, y son los únicos valores de este tipo.

+ **Number.** Los literales numéricos son construidos por una cadena de al menos un dígito (parte entera). Opcionalmente dicha cadena puede ser seguida por un punto (`.`) y otra cadena de al menos un dígito (parte fraccional). La representación de todo número será en base decimal y será perteneciente al tipo `number`. Nota: Todo `number` es un punto flotante.

#### Datos no manejables

+ **String**. La cadena de caracteres, o literal de *string*, es una secuencia de caracteres imprimibles encerrada en comillas dobles (`"`). Sólo se utilizan para instrucciones de ouput a consola y no son manejables con variables. Dicha secuencia no puede contener un salto de linea, comillas dobles o *backslashes* (`\`) a no ser de que estén escapados, es decir, `\n`, `\\` y `\"`.

+ **La imagen (Output)**. En Retina, similar a [Logo], existe una *tortuga* (cursor) al cual se le indica su movimiento en un plano cartesiano. No existe un tipo que represente una imagen, cada programa genera una única imagen.

#### Variables

Retina hace uso de variables. El identificador de una variable se forma por una cadena de caracteres de longitud arbitraria. Los caracteres permitidos van desde `a` hasta `z`, incluyendo sus respectivas mayúsculas, además de dígitos y el caracter guión bajo (`_`). Los identificadores no pueden comenzar con un dígito, guión bajo o un caracter en mayúscula. Son sensibles a mayúsculas.

*****

### Expresiones

Las expresiones están constituidas por variables, valores numéricos, booleanos y operadores. En el caso de una variable, al momento de acceder a su valor, independiente de su tipo, la misma debe haber sido declarada. Partiendo de una expresión `e`, de tipo cualquiera, se puede construir la expresión `(e)` y ambas van a producir el mismo valor, es decir, evaluar `(e)` conlleva a evaluar a `e`.

#### Operadores lógicos

Forman expresiones de tipo `boolean` a partir de operandos de tipo `boolean`. La precedencia de los operadores va desde la más alta a la más baja.

- `not`. Operador unario prefijo con asociatividad derecha. El valor correspondiente a la expresión formada será el contrario del operando.
- `and`. Operador binario infijo con asociatividad izquierda. El valor correspondiente a la expresión formada será la conjunción de los valores de cada operando.
- `or`. Operador binario infijo con asociatividad izquierda. El valor correspondiente a la expresión formada será la disyunción de los valores de cada operando.

#### Operadores de comparación

Forman expresiones de tipo `boolean` a partir de operandos de tipo `number`. Todos son operadores infijos y binarios y la precedencia de los operadores es la misma pero es menor al operador `not`, y mayor al operador `and` y `or`.

- `==`. Si ambos operandos son iguales, el valor de la expresión formada será `true`.
- `/=`. Si ambos operandos son desiguales, el valor de la expresión formada será `true`.
- `>=`. Si el operando izquierdo es mayor o igual al derecho, el valor de la expresión formada será `true`.
- `<=`. Si el operando izquierdo es menor o igual al derecho, el valor de la expresión formada será `true`.
- `>`. Si el operando izquierdo es mayor estricto al derecho, el valor de la expresión formada será `true`.
- `<`. Si el operando izquierdo es menor estricto al derecho, el valor de la expresión formada será `true`.

Para toda expresión formada por cualquiera de estos operadores, ésta será evaluada de izquierda a derecha. Además, los operadores `==` y `/=` también pueden formar expresiones a partir de operandos de tipo `boolean`.

#### Operadores aritméticos

Forman expresiones de tipo `number` a partir de operandos de tipo `number`. Estos operadores tienen mayor precedencia que los operadores de comparación. Se listan desde el operador con mayor precedencia.

- `-`. Operador unario, prefijo, asociatividad derecha. Se trata del "Menos unitario".
- `*`,`/`, `%`, `div` y `mod`. Operadores binarios, infijos, asociatividad izquierda. `/` y `%` corresponden a la división exacta y resto exacto entre los operandos, respectivamente.  `div` y `mod` corresponden a la división entera y resto entero entre los operandos, respectivamente. En caso de que el operando izquierdo sea `0` para todos los operandos excepto `*`, habrá error.
- `+` y `-` Operadores binarios, infijos, asociatividad izquierda. Corresponden a la suma y resta entre operandos.

*****

### Instrucciones

#### Declaración de variables (Bloques)

Es posible formar una instrucción de bloque `with DS do INSTR end;`, donde `DS` es una secuencia de declaraciones, la cual es opcional, y `INSTR` es una secuencia de instrucciones separadas por `;`.

Es posible indicar, en una misma linea, varias declaraciones a un mismo tipo, sólo si no se inicializa explícitamente alguna de las variables. Es decir que una declaración puede ser `TIPO ID1, ID2, ID3` para un tipo `TIPO` y un número indeterminado de IDs, o bien `TIPO ID = E`, con un solo `ID`, asignándole el valor de la expresión `E`.

Toda declaración de variable sin inicialización explícita tendrá una inicialización por defecto: `0` para variables de tipo `number` y `false` para las de tipo `boolean`.

La secuencia de declaraciones genera un contexto donde se hace disponible cada variable del tipo declarado asociado a un identificador; éstas no estarán disponibles fuera de ese contexto. Variables declaradas en bloques internos tienen precedencia (en caso de coincidir identificadores) frente a las de bloques más externos. No se permiten múltiples declaraciones del mismo identificador en el mismo bloque.

#### Asignación

Dado un identificador `I` y una expresión `E` de un tipo `T`, se puede formar una instrucción de asignación `I = E;`. El identificador `I` debe haber sido declarado con el mismo tipo `T` de la expresión, en caso contrario se arroja un error.

#### Control de flujo

##### Condicionales (If / Else)

Es posible tener una instrucción condicional con una secuencia de instruciones `INSTR` y una expresión `E` de tipo `boolean`. Donde `INSTR` será ejecutada sólo si `E` produce el valor `true`.
```
if E then INSTR end;
```
Puede indicarse, opcionalmente, una secuencia de instrucciones `OPT`, a realizarse si `E` produce el valor `false`.
```
if E then INSTR else OPT end;
```

##### While (Iteración indeterminada)

Dada una expresión `E` de tipo `boolean` y una secuencia de instrucciones `INSTR`, se ejecutarán las instrucciones en `INSTR` mientras `E` devuelva el valor `true`.
```
while E do INSTR end;
```

##### For (Iteración determinada)

A partir de un identificador `i`, y dos expresiones `A` y `B` de tipo `number`, se puede formar una instrucción de iteración determinada para ejecutar `INSTR` con `A<=i<=B`, en orden.
```
for i from A to B do INSTR end;
```
Es posible indicar el incremento (`P`) al final de cada iteración, que por defecto es `1`.
```
for i from A to B by P do INSTR end;
```
Es importante destacar que `A` y `B`, de no ser enteras, serán transformadas al entero más cercano por debajo.

###### Repeat (Caso particular)

Se puede construir una iteración determinada `repeat N times INSTR end;` como un caso particular de `for`, con una expresión `N` de tipo `number` y una secuencia de instrucciones `INSTR`. Dicha instrucción es equivalavente a `for i from 1 to N do INSTR end;` pero no existe un contador como variable.

#### Funciones

En Retina es posible definir una función con una secuencia de parámetros especificados `PR`, un identificador `F` y una secuencia de instrucciones `INSTR`, de la forma
```
func F(PR)
begin
  INSTR
end;
```
La secuencia de paramentros puede ser vacía, de lo contrario cada parametro estará separado por una coma `,` y será de la forma `TIPO ID`. Donde `TIPO` es el tipo de dato y `ID` es el identificador del parámetro como variable.

Opcionalmente se puede especificar un tipo de valor de retorno usando el lexema `->` y un tipo cualquiera `TIPORET`.
```
func F(PR) -> TIPORET
begin
    INSTR
end;
```

Se permite la recursión. Por el diseño de la gramática, no existe co-recursión.

#### Instrucciones de movimiento

Cada programa en Retina, inicia con el cursor en la posición (0,0) del plano cartesiano, viendo hacia arriba.

- `home()`: Sitúa el cursor en la posición (0,0).
- `openeye()`: Todo movimiento a partir de esta instrucción será marcado. En un principio, todo programa de Retina irá marcando el movimiento del cursor.
- `closeeye()`: Todo movimiento a partir de esta instrucción no se marcará.
- `forward(number x)`: Avanza el cursor el número pasos indicado como parámetro `x`.
- `backward(number x)`: Retrocede el cursor el número pasos indicado como parámetro `x`.
- `rotatel(number x)`: Rota el cursor en sentido antihorario el número de grados indicado como parámetro `x`.
- `rotater(number x)`: Rota el cursor en sentido horario el número de grados indicado como parámetro `x`.
- `setposition(number x, number y)`: Posiciona el cursor en el punto `(x, y)`.
- `arc(number x, number y)`: Dibuja un arco de `n` grados y radio `y`, con el cursor equidistante a todo punto del arco; sin marcar más que el arco, sin mover el cursor. _Esta función no ha sido implementada._

#### Entrada y salida (a consola)

##### Entrada

Teniendo un identificador `I`, asociado a un tipo de dato `T` en Retina, es posible leer una línea desde la entrada estandar del programa usando la instrucción `read I;`. Convirtiendo la línea recibida en un valor del tipo `T` y asociando dicho valor con el identificador `I`. Las conversiones exitosas serán las siguientes.
-  De tipo `boolean`, si los datos de entrada son exactamente `true` o `false`.
-  De tipo `number`, si los datos de entrada corresponden a un literal numérico de Retina. Ej. `27`, `37.73`

##### Salida

La instrucción `write x1, x2, ..., xn;`, donde `xi` puede ser una cadena de caracteres encerrada entre comillas dobles o una expresión de cualquier tipo. Recorre la secuencia de elementos de izquierda a derecha e imprime cada elemento en pantalla; esta secuencia no puede ser vacía. Existe la instrucción `writeln`, que realiza la imprisión descrita previamente y adicionalmente imprime un salto de línea al final.

*****

[//]: ### Referencias

[Especificación del Lenguaje Retina]: <https://github.com/dvdalilue/retina/blob/master/lenguaje/especificacion.md>
[Logo]: <http://el.media.mit.edu/logo-foundation/what_is_logo/logo_programming.html>
[pbm]: <https://en.wikipedia.org/wiki/Netpbm_format>
[Turtle graphics]: <https://en.wikipedia.org/wiki/Turtle_graphics>

*****
*****


## Rutyna

Por ahora la única documentación existente se encuentra en el código. Descárgalo, lée los comentarios, dibuja con Rutyna.
