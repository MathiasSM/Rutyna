####################################################################################################################################
## DESCRIPCIÓN:
####################################################################################################################################

# AST para el lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las especificaciones dadas para el proyecto del curso
# CI-3725 de la Universidad Simón Bolívar durante el trimestre Enero-Marzo 2017.

####################################################################################################################################
## AUTORES:
####################################################################################################################################

# Carlos Serrada, 13-11347, cserradag96@gmail.com
# Mathias San Miguel, 13-11310, mathiassanmiguel@gmail.com

####################################################################################################################################
## DECLARACIÓN DE LA CLASE PRINCIPAL
####################################################################################################################################

#-----------------------------------------------------------------------------------------------------------------------------------
# # AST (Abstract Syntaxis Tree)
#-----------------------------------------------------------------------------------------------------------------------------------
class AST
  def print_ast indent=""
    puts "#{indent}#{self.class}:"
    
    attrs.each do |a|
      a.print_ast indent + "|  " if a.respond_to? :print_ast
    end
  end
  
  def attrs
    instance_variables.map do |a|
      instance_variable_get a
    end
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# # Listas de AST
#-----------------------------------------------------------------------------------------------------------------------------------
class ASList < AST
  attr_accessor :l
  
  def initialize k=nil
    if k.nil?
      @l=[]
    else
      @l=[k]
    end
  end
  
  def print_ast indent=""
    @l.each do |a|
      a.print_ast indent if a.respond_to? :print_ast
    end
  end
  
  def joina asl
    @l = asl.l + @l
    return self
  end
end

####################################################################################################################################
## DECLARACIÓN DE LA JERARQUÍA DE CLASES DERIVADAS DE AST ENLAZADAS A LOS DESCUBRIMIENTOS DEL PARSER:
####################################################################################################################################

#-----------------------------------------------------------------------------------------------------------------------------------
# Generalización de operaciones por catidad de elementos involucrados:
#-----------------------------------------------------------------------------------------------------------------------------------

# Declaración de la clase general para operaciones unarias
class UnaryOperation < AST
  attr_accessor :operand
  
  def initialize operand
    @operand = operand
  end
end

# Declaración de la clase general para operaciones binarias
class BinaryOperation < AST
  attr_accessor :left, :right
  
  def initialize lh, rh
    @left = lh
    @right = rh
    @lname = "Left"
    @rname = "Right"
  end
  
  def name; end
  
  def print_ast indent=""
    self.name
    puts "#{indent}#{self.class}:"
    puts "#{indent}|  #{@lname}:"
    @left.print_ast  indent+"|  |  " if @left.respond_to? :print_ast
    puts "#{indent}|  #{@rname}:"
    @right.print_ast indent+"|  |  " if @right.respond_to? :print_ast
  end
end

# Declaración de la clase general para operaciones ternarias
class TernaryOperation < AST
  attr_accessor :left, :center, :right
  
  def initialize lh, ch, rh
    @left = lh
    @center = ch
    @right = rh
    @lname = ""
    @rname = ""
    @cname = ""
  end
  
  def name;end
  
  def print_ast indent=""
    self.name
    puts "#{indent}#{self.class}:"
    puts "#{indent}|  #{@lname}:"
    @left.print_ast indent+"|  |  " if @left.respond_to? :print_ast
    puts "#{indent}|  #{@cname}:"
    @center.print_ast indent+"|  |  " if @center.respond_to? :print_ast
    puts "#{indent}|  #{@rname}:"
    @right.print_ast indent+"|  |  " if @right.respond_to? :print_ast
  end
end

# Declaración de la clase especial para el bloque for
class ForBlock < AST
  attr_accessor :it, :ini, :fin, :paso, :instr
  
  def initialize it, ini, fin, paso, instr
    @it = it
    @ini = ini
    @fin = fin
    @paso = paso
    @instr = instr
  end
  
  def print_ast indent=""
    puts "#{indent}#{self.class}:"
    puts "#{indent}|  Iterator:"
    @it.print_ast indent+"|  |  " if @it.respond_to? :print_ast
    puts "#{indent}|  From:"
    @ini.print_ast indent+"|  |  " if @ini.respond_to? :print_ast
    puts "#{indent}|  To:"
    @fin.print_ast indent+"|  |  " if @fin.respond_to? :print_ast
    puts "#{indent}|  Step:"
    if @paso.respond_to? :print_ast
      @paso.print_ast indent+"|  |  "
    else
      puts indent+"|  |  1"
    end
    puts "#{indent}|  Intructions:"
    @instr.print_ast indent+"|  |  " if @instr.respond_to? :print_ast
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# Expresiones:
#-----------------------------------------------------------------------------------------------------------------------------------

# Declaración de la clase para expresiones del tipo Number
class SingleNumber < AST
  attr_accessor :number
  
  def initialize number
    @number = number
  end
  
  def print_ast indent=""
    puts "#{indent}#{self.class}: #{@number.to_str}"
  end
end

# Declaración de la clase para expresiones del tipo String
class SingleString < AST
  attr_accessor :string
  
  def initialize string
    @string = string
  end
  
  def print_ast indent=""
    puts "#{indent}#{self.class}: #{@string.to_str}"
  end
  
end

# Declaración de la clase para expresiones del tipo Boolean
class SingleBoolean < AST
  attr_accessor :boolean
  
  def initialize boolean
    @boolean = boolean
  end
  
  def print_ast indent=""
    puts "#{indent}#{self.class}: #{@boolean.to_str}"
  end
end

# Declaración de las clases individuales para las operaciones booleanas
class NegationOperation < UnaryOperation; end        # Negación
class ConjunctionOperation < BinaryOperation; end    # Conjunción
class DisjunctionOperation < BinaryOperation; end    # Disyunción
class EquivalentOperation < BinaryOperation; end     # Equivalencia
class DifferentOperation < BinaryOperation; end       # Diferencia
class GreaterOperation < BinaryOperation; end        # Mayor que
class LessOperation < BinaryOperation; end           # Menor que
class GreaterOrEqualOperation < BinaryOperation; end # Mayor o igual que
class LessOrEqualOperation < BinaryOperation; end    # Menor o igual que

# Declaración de las clases individuales para las operaciones aritmeticas
class UnaryMinusOperation < UnaryOperation; end      # Menos unitario
class AdditionOperation < BinaryOperation; end       # Suma
class SubtractionOperation < BinaryOperation; end    # Resta
class MultiplicationOperation < BinaryOperation; end # Multiplicación
class DivisionOperation < BinaryOperation; end       # División
class IntDivisionOperation < BinaryOperation; end    # División entera
class ModulusOperation < BinaryOperation; end        # Modulo
class ExactModulusOperation < BinaryOperation; end   # Modulo exacto

#-----------------------------------------------------------------------------------------------------------------------------------
# Instrucciones:
#-----------------------------------------------------------------------------------------------------------------------------------

# Asignación
class AssignmentInstruction < BinaryOperation
  def name
    @lname = "VarID"
    @rname = "Value"
  end
end

# Instrucción de return
class ReturnInstr < UnaryOperation
  def name
    @operand = "Value"
  end
end

# Llamado de función o procedimiento
class FunctionCall < BinaryOperation
  def name
    @lname = "Funcion"
    @rname = "Arguments"
  end
end

# Bloque program
class ProgramBlock < UnaryOperation; end

# Bloque with
class WithBlock < BinaryOperation
  def name
    @lname = "With"
    @rname = "Do"
  end
end

# Bloque if
class IfBlock < BinaryOperation
  def name
    @lname = "If"
    @rname = "Then"
  end
end

# Bloque if else
class IfElseBlock < TernaryOperation
  def name
    @lname = "If"
    @cname = "Then"
    @rname = "Else"
  end
end

# Bloque while
class WhileBlock < BinaryOperation
  def name
    @lname = "While"
    @rname = "Do"
  end
end

# Bloque repeat
class RepeatBlock < BinaryOperation
  def name
    @lname = "Times"
    @rname = "Instruction"
  end
end

class InputOperation < UnaryOperation; end  # Operaciones de entrada
class OutputOperation < UnaryOperation; end # Operaciones de salida

#-----------------------------------------------------------------------------------------------------------------------------------
# Declaraciones:
#-----------------------------------------------------------------------------------------------------------------------------------

# Declaración de variable simple
class SimpleStatement < BinaryOperation
  def name
    @lname = "Type"
    @rname = "VarID"
  end
end

# Declaración de variable con asignación
class AssignmentStatement < TernaryOperation
  def name
    @lname = "Type"
    @cname = "VarID"
    @rname = "Value"
  end
end

# Declaración de función
class FunctionStatement < AST
  attr_accessor :id, :param, :type, :instr
  def initialize id, param, type, instr
    @id = id
    @param = param
    @type = type
    @instr = instr
  end
  
  def print_ast indent=""
    puts "#{indent}#{self.class}:"; @id.print_ast indent+"|  " if @id.respond_to? :print_ast          # Imprimir identificados
    puts "#{indent}|  Params:";  @param.print_ast indent+"|  |  " if @param.respond_to? :print_ast    # Imprimir parametros
    if @type.respond_to? :print_ast
      puts "#{indent}|  Type:"; @type.print_ast indent+"|  |  "                # Imprimir tipo de dato de retorno si exists
    else
      puts "#{indent}|  Type: None"
    end                                                          # Imprimir None si no retorna nada
    puts "#{indent}|  Instr:"; @instr.print_ast indent+"|  |  " if @instr.respond_to? :print_ast      # Imprimir conjunto de instrucciones de la función
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# Tipos de datos:
#-----------------------------------------------------------------------------------------------------------------------------------

class Type < SingleString
  def print_ast indent=""
    puts "#{indent}#{@string.to_str}"
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# Identificadores:
#-----------------------------------------------------------------------------------------------------------------------------------

class VariableName < SingleString; end # Variables
class FunctionName < SingleString; end # Funciones

####################################################################################################################################
## FIN :)
####################################################################################################################################
