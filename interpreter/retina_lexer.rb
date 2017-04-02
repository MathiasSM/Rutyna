####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# LEXER para el lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las
# especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com


####################################################################################################
## REGEX de las palabras pertenencientes a Retina:
####################################################################################################

$tokens = {
    # Operadores de comparación
    # ==============================
    Equal:                 /\A\=\=/,
    NotEqual:              /\A\/\=/,
    GreaterOrEqualTo:      /\A\>\=/,
    LessOrEqualTo:         /\A\<\=/,
    GreaterThan:           /\A\>/,
    LessThan:              /\A\</,

    # Operadores especiales
    # ==============================
    ReturnType:            /\A\-\>/,

    # Operadores aritméticos
    # ==============================
    Plus:                  /\A\+/,
    Minus:                 /\A\-/,
    Asterisk:              /\A\*/,
    Slash:                 /\A\//,
    Percent:               /\A\%/,
    Mod:                   /\Amod(?![a-zA-Z0-9_])/,
    Div:                   /\Adiv(?![a-zA-Z0-9_])/,

    # Otros Signos
    # ==============================
    Assignment:            /\A\=/,
    OpenRoundBracket:      /\A\(/,
    CloseRoundBracket:     /\A\)/,
    Semicolon:             /\A;/,
    Comma:                 /\A,/,

    # Operadores lógicos
    # ==============================
    Not:                   /\Anot(?![a-zA-Z0-9_])/,
    And:                   /\Aand(?![a-zA-Z0-9_])/,
    Or:                    /\Aor(?![a-zA-Z0-9_])/,

    # Constantes booleanas
    # ==============================
    True:                  /\Atrue(?![a-zA-Z0-9_])/,
    False:                 /\Afalse(?![a-zA-Z0-9_])/,

    # Bloques
    # ==============================
    Program:               /\Aprogram(?![a-zA-Z0-9_])/,
    End:                   /\Aend(?![a-zA-Z0-9_])/,
    With:                  /\Awith(?![a-zA-Z0-9_])/,
    Do:                    /\Ado(?![a-zA-Z0-9_])/,
    While:                 /\Awhile(?![a-zA-Z0-9_])/,
    If:                    /\Aif(?![a-zA-Z0-9_])/,
    Then:                  /\Athen(?![a-zA-Z0-9_])/,
    Else:                  /\Aelse(?![a-zA-Z0-9_])/,
    For:                   /\Afor(?![a-zA-Z0-9_])/,
    From:                  /\Afrom(?![a-zA-Z0-9_])/,
    By:                    /\Aby(?![a-zA-Z0-9_])/,
    To:                    /\Ato(?![a-zA-Z0-9_])/,
    Repeat:                /\Arepeat(?![a-zA-Z0-9_])/,
    Times:                 /\Atimes(?![a-zA-Z0-9_])/,
    Function:              /\Afunc(?![a-zA-Z0-9_])/,
    Begin:                 /\Abegin(?![a-zA-Z0-9_])/,
    Return:                /\Areturn(?![a-zA-Z0-9_])/,

    # Tipos de datos
    # ==============================
    Boolean:               /\Aboolean(?![a-zA-Z0-9_])/,
    Number:                /\Anumber(?![a-zA-Z0-9_])/,

    # Métodos de Entrada/Salida
    # ==============================
    Read:                  /\Aread(?![a-zA-Z0-9_])/,
    Write:                 /\Awrite(?![a-zA-Z0-9_])/,
    WriteLine:             /\Awriteln(?![a-zA-Z0-9_])/,

    # Identificadores y literales
    # ==============================
    NumberLiteral:         /\A\d+(\.\d+)?/,
    FunctionIdentifier:    /\A[a-z][a-zA-Z0-9_]*(?=\()/,
    VariableIdentifier:    /\A[a-z][a-zA-Z0-9_]*/,
    StringLiteral:         /\A"(\\.|[^\\"\n])*"/
}

####################################################################################################
## CLASES para el uso de tokens:
####################################################################################################

# Clases padre
#=======================================
class Token
  attr_reader :t, :row, :col

  def initialize text, row=$row, col=$col
    @t = text
    @row = row
    @col = col
  end
  
  def to_s; "linea #{@row}, columna #{@col}: '#{@t}'"; end
  def to_str; "#{@t}"; end
end

# 'TOKEN' para CARACTER INVÁLIDO
#=======================================
class LexicographicError < RetinaError
  def initialize t
    @t = t
    @row = $row
    @col = $col
  end

  def to_s; "#{@@prompt} Error Lexicográfico: línea #{@row}, columna #{@col}: caracter inesperado \'#{@t}\'"; end
end


# TIPOS DE TOKENS
#=======================================

class PalabraReservada    < Token; def to_s; "linea #{@row}, columna #{@col}: palabra reservada \'#{@t}\'";         end; end
class Builtin             < Token; def to_s; "linea #{@row}, columna #{@col}: función builtin \'#{@t}\'";           end; end
class TipoDeDato          < Token; def to_s; "linea #{@row}, columna #{@col}: tipo de dato \'#{@t}\'";              end; end
class Signo               < Token; def to_s; "linea #{@row}, columna #{@col}: signo \'#{@t}\'";                     end; end

class FunctionIdentifier  < Token; def to_s; "linea #{@row}, columna #{@col}: identificador de funcion \'#{@t}\'";  end; end
class VariableIdentifier  < Token; def to_s; "linea #{@row}, columna #{@col}: identificador de variable \'#{@t}\'"; end; end

class StringLiteral       < Token; def to_s; "linea #{@row}, columna #{@col}: literal de string \'#{@t[1..-2]}\'";  end; end
class NumberLiteral       < Token
  def to_s; "linea #{@row}, columna #{@col}: literal numérico \'#{@t}\'";          end;
  def to_i; self.to_str.to_i; end;
  def to_f; self.to_str.to_f; end;
end
class BooleanLiteral      < Token; def to_s; "linea #{@row}, columna #{@col}: literal booleano \'#{@t}\'";          end; end

class True                < BooleanLiteral; end
class False               < BooleanLiteral; end

# SIGNOS
#=======================================
class Plus                < Signo; end
class Minus               < Signo; end
class Asterisk            < Signo; end
class Slash               < Signo; end
class Assignment          < Signo; end
class Percent             < Signo; end
class Mod                 < Signo; end
class Div                 < Signo; end
class Equal               < Signo; end
class NotEqual            < Signo; end
class GreaterOrEqualTo    < Signo; end
class LessOrEqualTo       < Signo; end
class GreaterThan         < Signo; end
class LessThan            < Signo; end
class Not                 < Signo; end
class And                 < Signo; end
class Or                  < Signo; end
class OpenRoundBracket    < Signo; end
class CloseRoundBracket   < Signo; end
class Semicolon           < Signo; end
class Comma               < Signo; end

# PALABRAS RESERVADAS
#=======================================
class Program             < PalabraReservada; end
class End                 < PalabraReservada; end
class With                < PalabraReservada; end
class Do                  < PalabraReservada; end
class While               < PalabraReservada; end
class If                  < PalabraReservada; end
class Then                < PalabraReservada; end
class Else                < PalabraReservada; end
class For                 < PalabraReservada; end
class From                < PalabraReservada; end
class By                  < PalabraReservada; end
class To                  < PalabraReservada; end
class Repeat              < PalabraReservada; end
class Times               < PalabraReservada; end
class Function            < PalabraReservada; end
class Begin               < PalabraReservada; end
class Return              < PalabraReservada; end
class ReturnType          < PalabraReservada; end

# FUNCIONES BUILTIN
#=======================================
class Read                < Builtin; end
class Write               < Builtin; end
class WriteLine           < Builtin; end

# ESPECIFICACIÓN DE TIPOS
#=======================================
class Number              < TipoDeDato; end
class Boolean             < TipoDeDato; end



####################################################################################################
## LEXER:
####################################################################################################

class Lexer
  attr_reader :tokens

  # Inicialización
  # ================================
  def initialize input
      @tokens = []
      @input = input
  end

  # Función para CAPTURAR los lexemas
  # ================================
  def catch_lexeme
    while @input =~ /(\A[^\S\n\r]*(\#[^\n]*)?[\n\r])|(\A\#.*$)/ do    # Salta líneas blancas o con comentarios
      @input = @input[$&.length..@input.length-1]
      $row = $row+1                                                   # Ve línea por línea sumando a $row
      $col = 1                                                        # Resetea $col a 1
    end
    @input =~ /\A[^\S\n\r]*/                                          # Ignora espacio en blanco inicial
    return if @input.empty?                                           # Retorna nil si no hay input
    $col = $col+$&.length if $&.length > 0                            # Pero lo suma a las columnas
    @input = $'

    class_to_be_instanciated = LexicographicError

    # Chequeos con cada regex, en orden
    $tokens.each do |k,v|
      if @input =~ v
        class_to_be_instanciated = Object::const_get(k)
        break
      end
    end

    # Si NO hay match, hay error, lo mete como token de error.
    if $&.nil? and class_to_be_instanciated.eql? LexicographicError
      # @input =~ /\A(\w|\p{punct})/
      # @tokens << LexicographicError.new($&)
      # $col = $col + $&.length
      raise LexicographicError.new($&)

    # Si SI hay match, mete lo que matcheó
    else
      @tokens << class_to_be_instanciated.new($&)
      $col = $col + $&.length
    end

    # En ambos casos actualiza el $col
    @input = @input[$&.length..@input.length-1]
    return @tokens[-1]
  end
end

####################################################################################################
####################################################################################################
