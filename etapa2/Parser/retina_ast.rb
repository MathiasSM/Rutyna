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
class BooleanExpression < AST
    attr_accessor :boolean

    def initialize boolean
        @boolean = boolean
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@boolean.to_b}"
    end
end

# Declaración de la clase para expresiones del tipo Number
class NumberExpression < AST
    attr_accessor :number

    def initialize number
        @number = number
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@number.to_i}"
    end
end

# Declaración de la clase para expresiones del tipo Number
class StringExpression < AST
    attr_accessor :string

    def initialize string
        @string = string
    end

    def print_ast indent=""
        puts "#{indent}#{self.class}: #{@string.to_str}"
    end

end

# Declaración de la clase general para operaciones unarias
class UnaryOperator < AST
    attr_accessor :operand

    def initialize operand
        @operand = operand
    end
end

# Declaración de la clase general para operaciones binarias
class BinaryOperator < AST
    attr_accessor :left, :right

    def initialize lh, rh
        @left = lh
        @right = rh
    end
end

# Declaración de la clase general para operaciones ternarias
class TernaryOperator < AST
    attr_accessor :left, :center, :right

    def initialize lh, ch, rh
        @left = lh
        @center = ch
        @right = rh
    end
end

# Declaración de las clases individuales para las operaciones booleanas
class NegationOperator < UnaryOperator; end        # Negación
class ConjunctionOperator < BinaryOperator; end    # Conjunción
class DisjunctionOperator < BinaryOperator; end    # Disyunción
class EquivalentOperator < BinaryOperator; end     # Equivalencia
class DiferentOperator < BinaryOperator; end       # Diferencia
class GreaterOperator < BinaryOperator; end        # Mayor que
class LessOperator < BinaryOperator; end           # Menor que
class GreaterOrEqualOperator < BinaryOperator; end # Mayor o igual que
class LessOrEqualOperator < BinaryOperator; end    # Menor o igual que

# Declaración de las clases individuales para las operaciones aritmeticas
class UnaryMinusOperator < UnaryOperator; end      # Menos unitario
class AdditionOperator < BinaryOperator; end       # Suma
class SubtractionOperator < BinaryOperator; end    # Resta
class MultiplicationOperator < BinaryOperator; end # Multiplicación
class DivisionOperator < BinaryOperator; end       # División
class IntDivisionOperator < BinaryOperator; end    # División entera
class ModulusOperator < BinaryOperator; end        # Modulo
class ExactlyModulusOperator < BinaryOperator; end # Modulo exacto

# Declaración de las clases individuales para bloques
class ProgramBlock < UnaryOperator; end   # Bloque program
class WithBlock < UnaryOperator; end      # Bloque with
class IfBlock < BinaryOperator; end       # Bloque if
class WhileBlock < BinaryOperator; end    # Bloque while
class ForBlock < BinaryOperator; end      # Bloque for
class RepeatBlock < BinaryOperator; end   # Bloque repeat
class TimesBlock < BinaryOperator; end    # Bloque times
class FunctionBlock < BinaryOperator; end # Bloque function
class BeginBlock < UnaryOperator; end     # Bloque begin
class ReturnBlock < BinaryOperator; end   # Bloque return

# Declaración de clases individuales para expresiones
class TrueExpression < UnaryOperator; end  # True
class FalseExpression < UnaryOperator; end # False

# Declaración de clases individuales para declaraciones
class SimpleStatement < BinaryOperator; end      # Declaración
class AssignmentStatement < TernaryOperator; end # Declaración con asignación

# Declaración de clases individuales para instrucciones
class AssignmentInstruction < BinaryOperator; end # Asignación

#  Declaración de clases individuales para los lobos solitarios
class VariableName < UnaryOperator; end # Identificador de variable
class FunctionName < UnaryOperator; end # Identificador de variable



