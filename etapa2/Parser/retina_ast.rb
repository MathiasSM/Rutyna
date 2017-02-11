# Declaración de la clase AST (Abstract Syntaxis Tree)
class AST
    def print_ast indent=""
        puts "#{indent}#{self.class}:"

        attrs.each do |a|
            a.print_ast indent + "  " if a.respond_to? :print_ast
        end
    end

    def attrs
        instance_variables.map do |a|
            instance_variable_get a
        end
    end
end

class ASList < AST
    attr_accessor :l

    def initialize k=None
        @l = [k]
    end

    def print_ast indent=""
        @l.each do |a|
            a.print_ast indent + "  " if a.respond_to? :print_ast
        end
    end

    def join asl
        @l += asl
    end
end

# Declaración de la clase para expresiones del tipo Boolean
class SingleBoolean < AST
    attr_accessor :boolean

    def initialize boolean
        @boolean = boolean
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@boolean.to_b}"
    end
end

# Declaración de la clase para expresiones del tipo Number
class SingleNumber < AST
    attr_accessor :number

    def initialize number
        @number = number
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@number.to_i}"
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
    end
end

# Declaración de la clase general para operaciones ternarias
class TernaryOperation < AST
    attr_accessor :left, :center, :right

    def initialize lh, ch, rh
        @left = lh
        @center = ch
        @right = rh
    end
end

# Declaración de la clase especial para el FOR
class ForOperation < AST
    attr_accessor :it, :ini, :fin, :paso, :instr

    def initialize it, ini, fin, paso, instr
        @it = it
        @ini = init
        @fin = fin
        @paso = paso
        @instr = instr
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
class ExactModulusOperation < BinaryOperation; end # Modulo exacto

# Declaración de las clases individuales para bloques
class ProgramBlock < UnaryOperation; end
class WithBlock < BinaryOperation
    def print_ast indent=""
        puts "#{indent}#{self.class}:"
        puts "#{indent}  with:"
        @left.print_ast indent+"    " if @left.respond_to? :print_ast
        puts "#{indent}  do:"
        @right.print_ast indent+"    " if @right.respond_to? :print_ast
    end
end     # Bloque with
class IfBlock < BinaryOperation; end       # Bloque if
class IfElseBlock < TernaryOperation; end  # Bloque if/else
class WhileBlock < BinaryOperation; end    # Bloque while
class RepeatBlock < BinaryOperation; end   # Bloque repeat

# Declaración de clases individuales para expresiones
class SingleTrue < SingleBoolean; end  # True
class SingleFalse < SingleBoolean; end # False

# Declaración de clases individuales para declaraciones
class SimpleStatement < BinaryOperation; end      # Declaración
class AssignmentStatement < TernaryOperation; end # Declaración con asignación

# Declaración de Función
class FunctionStatement < AST
    attr_accessor :id, :param, :type, :instr

    def initialize id, param, type, instr
        @id = id
        @param = param
        @type = type
        @instr = instr
    end
end # Bloque function

# Declaración de clases individuales para instrucciones
class AssignmentInstruction < BinaryOperation; end # Asignación

#  Declaración de clases individuales para los lobos solitarios
class VariableName < UnaryOperation; end # Identificador de variable
class FunctionName < BinaryOperation; end # Identificador de variable



