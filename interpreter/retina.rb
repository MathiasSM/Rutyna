#!/usr/bin/env ruby

####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# INTERPRETADOR para el lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las
# especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com

# ALCANCE ACTUAL
# =====================
# - Análisis Lexicográfico  :Listo
# - Análisis Sintáctico     :Listo
# - Análisis de Contexto    :Listo
# - Intérprete Final        :Próximamente

# REQUIERE
# =====================
# retina_lexer.rb
# retina_parser.rb (creado a partir de `racc retina_parser.y`)
# retina_ast.rb



####################################################################################################
## CUSTOM ERROR:
####################################################################################################

class RetinaError < RuntimeError
  @@prompt = "Retina:"
end

class LexicographicError < RetinaError
  def initialize t
    @t = t
    @row = $row
    @col = $col
  end

  def to_s; "#{@@prompt} Error Lexicográfico: Caracter inesperado \'#{@t}\' (línea #{@row}, columna #{@col})"; end
end

class SyntacticError < RetinaError
  def initialize token
    @token = token
  end

  def to_s
    "#{@@prompt} Error de Sintáxis: Token inesperado \'#{@token.to_str}\' (linea #{@token.row}, columna #{@token.col})"
  end
end

class ContextError < RetinaError
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end

  def to_s
    "#{@@prompt} Error de contexto: #{@mensaje} (#{@nodo.name} en línea #{@nodo.row})"
  end
end

class ExecutionError < RetinaError
  attr_accessor :mensaje
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end

  def to_s
    "#{@@prompt} Error de Ejecución: #{@mensaje} (#{@nodo.name} en línea #{@nodo.row})"
  end
end

class InterpreterError < RetinaError
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end

  def to_s
    "#{@@prompt} Error del Interpretador (bug): #{@mensaje} (#{@nodo.name} en línea #{@nodo.row})"
  end
end



####################################################################################################
## LIBRERÍAS:
####################################################################################################

require_relative 'retina_parser'    # Librería que contiene el parser de Retina
require_relative 'retina_geometry'  # Librería que contiene reglas y compases
require_relative 'retina_draw'      # Librería que contiene dibujitos y rayones



####################################################################################################
## DECLRACIÓN DE FUNCIONES:
####################################################################################################


def main
  # LECTURA (chequeo de .ext y abrir como string)
  # ================================
  ARGV[0] =~ /\w+\.rtn/
  if $&.nil?
    puts "Tipo de archivo no reconocido\nPor favor utilice un archivo 'file.rtn'"
    exit 1
  end

  begin
    input = File::read(ARGV[0])
  rescue
    puts "No se encontró el archivo"
    exit 1
  end

  # Atrapa LEXEMAS
  # ================================
  begin
    ## Análisis lexicográfico previo
    # $row = 1; $col = 1        # Contamos líneas y columnas desde 1
    # lexer = Lexer.new input   # Inicializamos Lexer con el input del archivo
    # while lexer.catch_lexeme; end

    begin
      $debug = false
      $row = 1; $col = 1        # Contamos líneas y columnas desde 1
      lexer = Lexer.new input   # Inicializamos Lexer con el input del archivo
      parser = Parser.new       # Inicializamos Parser
      $paint = CapasPintura.new
      ast = parser.parse lexer  # Creamos el AST de prueba a partir del output del Parser
      ast.execute
      crearImagen procesarCapa
      
    rescue LexicographicError => e  # Al primer error de sintáxis salimos corriendo
      puts e
      exit 1
      
    rescue SyntacticError => e  # Al primer error de sintáxis salimos corriendo
      puts e
      exit 1

    rescue ContextError => e  # Al primer error de sintáxis salimos corriendo
      puts e
      exit 1

    rescue ExecutionError => e  # Al primer error de sintáxis salimos corriendo
      puts e
      exit 1
    
    end
  end
end

####################################################################################################
## PROGRAMA PRINCIPAL:
####################################################################################################

main
