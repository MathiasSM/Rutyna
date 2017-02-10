class Parser
    # Lista de tokens
    token '==' '!=' '>=' '<=' '>' '<' '->' '+' '-' '*' '/' '%' 'mod' 'div' '=' '(' ')' ';' ',' 'not' 'and' 'or' 'true' 'false' 'program' 'end' 'with' 'do' 'while' 'if' 'then' 'else' 'for' 'from' 'by' 'to' 'repeat' 'times' 'function' 'begin' 'return' 'boolean' 'number' 'openeye' 'closeeye' 'backward' 'forward' 'rotatel' 'rotater' 'setposition' 'arc' 'read' 'write' 'writeline' 'num' 'funid' 'varid' 'str' UMINUS

    # Tabla de presedencia
    prechigh
        right 'not'
        nonassoc UMINUS
        left '*' '/' 'div' 'mod' '%'
        left '+' '-'
        left '<=' '>=' '<' '>'
        left '=='
        left 'or' 'and'
        right '='
    preclow

    # Lista de conversiones de tokens a clases
    convert
        # Tipos
        'boolean' 'Boolean'
        'number'  'Number'

        # Operadores de comparación
        '==' 'Equal'
        '!=' 'NotEqual'
        '>=' 'GreaterOrEqualTo'
        '<=' 'LessOrEqualTo'
        '>'  'GreaterThan'
        '<'  'LessThan'

        # Operadores especiales
        '->' 'ReturnType'

        # Operadores aritméticos
        '+'   'Plus'
        '-'   'Minus'
        '*'   'Asterisk'
        '/'   'Slash'
        '%'   'Percent'
        'mod' 'Mod'
        'div' 'Div'

        # Signos
        '=' 'Assignment'
        '(' 'OpenRoundBracket'
        ')' 'CloseRoundBracket'
        ';' 'Semicolon'
        ',' 'Comma'

        # Operadores lógicos
        'not' 'Not'
        'and' 'And'
        'or'  'Or'

        # Constantes booleanas
        'true'  'True'
        'false' 'False'

        # Bloques
        'program'  'Program'
        'end'      'End'
        'with'     'With'
        'do'       'Do'
        'while'    'While'
        'if'       'If'
        'then'     'Then'
        'else'     'Else'
        'for'      'For'
        'from'     'From'
        'by'       'By'
        'to'       'To'
        'repeat'   'Repeat'
        'times'    'Times'
        'function' 'Function'
        'begin'    'Begin'
        'return'   'Return'

        # Funciones (No se si esto va aquí)
        'openeye'     'OpenEye'
        'closeeye'    'CloseEye'
        'backward'    'Backward'
        'forward'     'Forward'
        'rotatel'     'RotateL'
        'rotater'     'RotateR'
        'setposition' 'SetPosition'
        'arc'         'Arc'
        'read'        'Read'
        'write'       'Write'
        'writeline'   'WriteLine'

        'num'   'NumberLiteral'
        'funid' 'FunctionIdentifier'
        'varid' 'VariableIdentifier'
        'str'   'StringLiteral'

end

start Retina

# Declaración de las reglas de la gramatica
rule

    Expression:   'num'                       { result = NumberExpression.new(val[0])               }
                | 'true'                      { result = TrueExpression.new(val[0])                 }
                | 'false'                     { result = FalseExpression.new(val[0])                }
                | 'str'                       { result = StringExpression.new(val[0])               }
                | 'varid'                     { result = VariableName.new(val[0])                   }
                | '-' Expression = UMINUS     { result = UnaryMinusOperator.new(val[1])             }
                | 'not' Expression            { result = NegationOperator.new(val[1])               }
                | Expression '*' Expression   { result = MultiplicationOperator.new(val[0], val[2]) }
                | Expression '/' Expression   { result = DivisionOperator.new(val[0], val[2])       }
                | Expression 'div' Expression { result = IntDivisionOperator.new(val[0], val[2])    }
                | Expression 'mod' Expression { result = ModulusOperator.new(val[0], val[2])        }
                | Expression '%' Expression   { result = ExactylModulusOperator.new(val[0], val[2]) }
                | Expression '+' Expression   { result = AdditionOperator.new(val[0], val[2])       }
                | Expression '-' Expression   { result = SubtractionOperator.new(val[0], val[2])    }
                | Expression '==' Expression  { result = EquivalentOperator.new(val[0], val[2])     }
                | Expression '!=' Expression  { result = DiferentOperator.new(val[0], val[2])       }
                | Expression '<=' Expression  { result = LessOrEqualOperator.new(val[0], val[2])    }
                | Expression '>=' Expression  { result = GreaterOrEqualOperator.new(val[0], val[2]) }
                | Expression '<' Expression   { result = LessOperator.new(val[0], val[2])           }
                | Expression '>' Expression   { result = GreaterOperator.new(val[0], val[2])        }
                | Expression 'or' Expression  { result = DisyunctionOperator.new(val[0], val[2])    }
                | Expression 'and' Expression { result = ConjunctionOperator.new(val[0], val[2])    }
                | '(' Expression ')'          { result = val[1]                                     }
    ;

    Datatype:     'boolean' { result = val[0] }
                | 'number'  { result = val[0] }
    ;

    Statement:    Datatype 'varid'                { result = SimpleStatement.new(val[0], val[1])                       }
                | Datatype 'varid' '=' Expression { result = AssignmentStatement.new(val[0], val[1], val[3]) }
    ;

    Instruction:  'varid' '=' Expression { result = AssignmentInstruction.new(val[0], val[2]) }
    ;

    Statements:   Statement                { result = val[0]            }
                | Statements ';' Statement { result = val[0] + [val[1]] }
    ;

    Instructions: Instruction                   { result = val[0]            }
                | Instructions ';' Instruction  { result = val[0] + [val[2]] }
    ;

    Params:       Statement                { result = val[0]            }
                | Statements ',' Statement { result = val[0] + [val[2]] }
    ;

    Blocks:       'with' Statements 'do' Instructions 'end'                              { result = WithBlock.new(val[1])           }
                | 'func' 'funid' Params '->' Datatype 'begin' Instructions 'end'         { result = FunctionBlock.new(val[1])       }
                | 'while' Expression 'do' Instructions 'end'                             { result = WhileBlock.new(val[1])          }
                | 'for' 'num' 'from' 'num' 'to' 'num' 'by' 'num' 'do' Instructions 'end' { result = ForBlock.new(val[1])            }
                | 'if' Expression 'then' Instructions 'end'                              { result = IfBlock.new(val[1], val[3])     }
                | 'if' Expression 'then' Instructions 'else' Instructions 'end'          { result = IfElseBlock.new(val[1], val[3]) }
    ;

    Retina: 'program' Blocks 'end' { result = ProgramBlock.new(val[1]) }
    ;

---- header

require_relative "retina_lexer"
require_relative "retina_ast"

class SyntacticError < RuntimeError

    def initialize(tok)
        @token = tok
    end

    def to_s
        "Syntactic error on: #{@token}"
    end
end

---- inner

def on_error(id, token, stack)
    raise SyntacticError::new(token)
end

def next_token
    token = @lexer.catch_lexeme
    return [false,false] unless token
    return [token.class,token]
end

def parse(lexer)
    @yydebug = true
    @lexer = lexer
    @tokens = []
    ast = do_parse
    return ast
end
