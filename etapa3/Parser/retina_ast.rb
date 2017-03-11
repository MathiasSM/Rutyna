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
  
  
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    attrs.each do |a|
      a.recorrer() if a.respond_to? :recorrer
    end
  end
end

class Row
  attr_accessor :name, :type, :value
  
  def initialize name, type=nil, value=nil
    @name = name
    @type = type
    @value = value
  end
  
  def print_row indent=""
    puts "#{indent}#{@name} : #{@type}"
  end
end

class SymbolTable
  attr_accessor :table
  
  def initialize
    @table = []
  end
end

class SymbolMetaTable
  attr_accessor :meta
  
  def initialize
    @meta = [SymbolTable.new()]
  end
  
  def lookfor symbol
    scope_depth = 0
    @meta.reverse.each do |scope|
      scope.table.each do |row|
        if row.name == symbol
          return scope_depth, (row.type), (row.value)
        end
      end
      scope_depth += 1
    end
    return -1, "None", 0
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
  
  def recorrer indent=""
    r = []
    @l.each do |a|
      r.push(a.recorrer indent) if a.respond_to? :recorrer
    end
    return r
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
  
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    puts "#{indent}ForBlock"
    puts "#{indent}|  #{@it.to_str} : number"
    $stt.meta += [(SymbolTable.new())]
    ini.recorrer indent+"|  "   if ini.respond_to? :recorrer
    fin.recorrer indent+"|  "   if fin.respond_to? :recorrer
    paso.recorrer indent+"|  "  if paso.respond_to? :recorrer
    instr.recorrer indent+"|  " if instr.respond_to? :recorrer
    $stt.meta.pop
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
  
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    return @number.to_str.to_f, "number" # Valor, Tipo
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
  
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    return @string.to_str # Valor
  end
  
  def to_str
    "#{@string.to_str}"
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
  
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    return (@boolean.to_str == "true"), "boolean" # Valor, Tipo
  end
end

# Declaración de las clases individuales para las operaciones booleanas
class NegationOperation < UnaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v,t = @operand.recorrer indent
    if t != "boolean"
      $stderr.puts ContextError::new(t,"boolean",self.class)
    else
      return (not v), "boolean" # Valor, Tipo
    end
  end
end        # Negación
class ConjunctionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "boolean"
      $stderr.puts ContextError::new(t1,"boolean",self.class)
    elsif t2!="boolean"
      $stderr.puts ContextError::new(t2,"boolean",self.class)
    else
      return (v1 and v2), "boolean" # Valor, Tipo
    end
  end
end    # Conjunción
class DisjunctionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "boolean"
      $stderr.puts ContextError::new(t1,"boolean",self.class)
    elsif t2!="boolean"
      $stderr.puts ContextError::new(t2,"boolean",self.class)
    else
      return (v1 or v2), "boolean" # Valor, Tipo
    end
  end
end    # Disyunción
class EquivalentOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != t2
      $stderr.puts ContextError::new(t1,t2,0)
    else
      return (v1 == v2), "boolean" # Valor, Tipo
    end
  end
end     # Equivalencia
class DifferentOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != t2
      $stderr.puts ContextError::new(t1,t2,0)
    else
      return (v1 != v2), "boolean" # Valor, Tipo
    end
  end
end       # Diferencia
class GreaterOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 > v2), "boolean" # Valor, Tipo
    end
  end
end        # Mayor que
class LessOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 < v2), "boolean" # Valor, Tipo
    end
  end
end           # Menor que
class GreaterOrEqualOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 >= v2), "boolean" # Valor, Tipo
    end
  end
end # Mayor o igual que
class LessOrEqualOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 <= v2), "boolean" # Valor, Tipo
    end
  end
end    # Menor o igual que

# Declaración de las clases individuales para las operaciones aritmeticas
class UnaryMinusOperation < UnaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v,t = @operand.recorrer indent
    if t != "number"
      $stderr.puts ContextError::new(t,"number",self.class)
    else
      return (-v), "number"
    end
  end
end      # Menos unitario
class AdditionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
        $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 + v2), "number" # Valor, Tipo
    end
  end
end       # Suma
class SubtractionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 - v2), "number" # Valor, Tipo
    end
  end
end    # Resta
class MultiplicationOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 * v2), "number" # Valor, Tipo
    end
  end
end # Multiplicación
class DivisionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 / v2), "number" # Valor, Tipo
    end
  end
end       # División
class IntDivisionOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 / v2), "number" # Valor, Tipo
    end
  end
end    # División entera
class ModulusOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 % v2), "number" # Valor, Tipo
    end
  end
end        # Modulo
class ExactModulusOperation < BinaryOperation
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    v1,t1 = @left.recorrer indent
    v2,t2 = @right.recorrer indent
    if t1 != "number"
      $stderr.puts ContextError::new(t1,"number",self.class)
    elsif t2!="number"
      $stderr.puts ContextError::new(t2,"number",self.class)
    else
      return (v1 % v2), "number" # Valor, Tipo
    end
  end
end   # Modulo exacto

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
  def recorrer indent=""
    # puts "#{indent}#{self.class}"
    return 0, "None"
  end
end

# Bloque program
class ProgramBlock < AST
  attr_accessor :instrs
  
  def initialize instrs
    @instrs = instrs
  end
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    $stt.meta += [(SymbolTable.new())]
    puts indent+"Programa"
    instrs.recorrer indent="|  " if instrs.respond_to? :recorrer
    $stt.meta.pop
  end
end

# Bloque with
class WithBlock < BinaryOperation
  def name
    @lname = "With"
    @rname = "Do"
  end
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    $stt.meta += [(SymbolTable.new())]
    puts "#{indent}WithDo"
    @left.recorrer indent+"|  " if left.respond_to? :recorrer
    @right.recorrer indent+"|  " if right.respond_to? :recorrer
    $stt.meta.pop
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
  def recorrer indent=""
    #        puts "#{indent}#{self.class}"
    $stt.meta += [(SymbolTable.new())]
    left.recorrer indent if left.respond_to? :recorrer
    right.recorrer indent if right.respond_to? :recorrer
    $stt.meta.pop
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
  
  def recorrer indent=""
    vs = @right.recorrer indent+"|  " if @right.respond_to? :recorrer
    
    vs.each do |v|
   
      s = $stt.lookfor v[0]
      
      if scope == 0
        $stderr.puts ContextError::new("0","1 (Variable/Funcion ya declarada!)",self.class)
      else
        return value, type
      end
    
      $stt.meta[-1].table += [Row.new(v[1], v[0])]
    end
    $stt.meta[-1].table[-1].print_row indent
  end
end

# Declaración de variable con asignación
class AssignmentStatement < TernaryOperation
  def name
    @lname = "Type"
    @cname = "VarID"
    @rname = "Value"
  end
  def recorrer indent=""
    v,t = @right.recorrer indent+"|  " if @right.respond_to? :recorrer
    
    scope, type, value = $stt.lookfor @center.to_str
    
    if scope == 0
      $stderr.puts ContextError::new("0","1 (Variable/Funcion ya declarada!)",self.class)
    elsif @left.to_str != t
      $stderr.puts ContextError::new("#{type}","#{t} (Error de tipo!)",self.class)
    else
      return value, type
    end
    
    $stt.meta[-1].table += [Row.new(@center.to_str, @left.to_str, v)]
    $stt.meta[-1].table[-1].print_row indent
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
  
  
  def recorrer indent=""
    if not @type
      $stt.meta[-1].table += [Row.new(@id.to_str, @type.to_str)]
    else
      $stt.meta[-1].table += [Row.new(@id.to_str, "None")]
    end
    $stt.meta[-1].table[-1].print_row indent+"Funcion -> "
    
    $stt.meta += [SymbolTable.new()]
    @param.recorrer indent+"|  " if @param.respond_to? :recorrer
    @instr.recorrer indent+"|  " if @instr.respond_to? :recorrer
    $stt.meta.pop
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# Tipos de datos:
#-----------------------------------------------------------------------------------------------------------------------------------

class Type < SingleString
  def print_ast indent=""
    puts "#{indent}#{@string.to_str}"
  end
  
  def to_str
    @string.to_str
  end
end

#-----------------------------------------------------------------------------------------------------------------------------------
# Identificadores:
#-----------------------------------------------------------------------------------------------------------------------------------

class VariableName < SingleString
  def recorrer indent=""
    # Revisar tabla para saber tipo
    return 0, "number" # Valor,Tipo
  end
end # Variables
class FunctionName < SingleString
  def recorrer indent=""
    # Revisar tabla para saber tipo
    return 0, "number" # Valor,Tipo
  end
end # Funciones


###
####
class ContextError < RuntimeError
  
  def initialize v1, v2, place
    @v1 = v1
    @v2 = v2
    @place = place
  end
  
  def to_s
    "Error de contexto: #{@v1} != #{@v2}. En línea #{@place}"
  end
end


####################################################################################################################################
## FIN :)
####################################################################################################################################
