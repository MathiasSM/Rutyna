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

# Declaración de la clase para expresiones del tipo Boolean
class BooleanType < AST
    attr_accessor :boolean

    def initialize boolean
        @boolean = boolean
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@boolean.to_b}"
    end
end

# Declaración de la clase para expresiones del tipo Number
class NumberType < AST
    attr_accessor :number

    def initialize number
        @number = number
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@number.to_i}"
    end
end

class StringType < AST
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

# Declaración de las clases individuales para las operaciones booleanas
class Negation < UnaryOperation; end        # Negación
class Conjunction < BinaryOperation; end    # Conjunción
class Disjunction < BinaryOperation; end    # Disyunción
class Equivalent < BinaryOperation; end     # Equivalencia
class Diferent < BinaryOperation; end       # Diferencia
class Greater < BinaryOperation; end        # Mayor que
class Less < BinaryOperation; end           # Menor que
class GreaterOrEqual < BinaryOperation; end # Mayor o igual que
class LessOrEqual < BinaryOperation; end    # Menor o igual que

# Declaración de las clases individuales para las operaciones aritmeticas
class UnaryMinus < UnaryOperation; end      # Menos unitario
class Addition < BinaryOperation; end       # Suma
class Subtraction < BinaryOperation; end    # Resta
class Multiplication < BinaryOperation; end # Multiplicación
class Division < BinaryOperation; end       # División
class IntDivision < BinaryOperation; end    # División entera
class Modulus < BinaryOperation; end        # Modulo
class ExactlyModulus < BinaryOperation; end # Modulo exacto

# Declaración de las clases individuales para bloques
class ProgramBlock < UnaryOperation; end   # Bloque program
class WithBlock < UnaryOperation; end      # Bloque with
class IfBlock < BinaryOperation; end       # Bloque if
class WhileBlock < BinaryOperation; end    # Bloque while
class ForBlock < BinaryOperation; end      # Bloque for
class RepeatBlock < BinaryOperation; end   # Bloque repeat
class TimesBlock < BinaryOperation; end    # Bloque times
class FunctionBlock < BinaryOperation; end # Bloque function
class BeginBlock < UnaryOperation; end     # Bloque begin
class ReturnBlock < BinaryOperation; end   # Bloque return

# Declaración de clases individuales para instrucciones
class AssignmentInst < BinaryOperation; end        # Assignment
class Identifier < UnaryOperation; end             # Negación
class Declare < BinaryOperation; end               # Declaración
class DeclareWithAssignment < TernaryOperation; end # Declaración con asignación
class TrueExp < UnaryOperation; end
class FalseExp < UnaryOperation; end
