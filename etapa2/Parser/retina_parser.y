class Parser
    # Lista de tokens
    token '==' '!=' '>=' '<=' '>' '<' '->' '+' '-' '*' '/' '%' 'mod' 'div' '=' '(' ')' ';' ',' 'not' 'and' 'or' 'true' 'false' 'program' 'end' 'with' 'do' 'while' 'if' 'then' 'else' 'for' 'from' 'by' 'to' 'repeat' 'times' 'function' 'begin' 'return' 'boolean' 'number' 'openeye' 'closeeye' 'backward' 'forward' 'rotatel' 'rotater' 'setposition' 'arc' 'read' 'write' 'writeline' UMINUS

    # Tabla de presedencia
    prechigh
        nonassoc UMINUS 'not'
        left '*' '/' 'div' 'mod' '%'
        left '+' '-'
        nonassoc '<=' '>=' '<' '>'
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

        'num'    'NumberLiteral'
        'id'     'VariableIdentifier'
        'string' 'StringLiteral'

end

start Retina

# Declaración de las reglas de la gramatica
rule

    Expression:   'num'                       { result = NumberType.new(val[0])             }
                | 'true'                      { result = TrueExp.new(val[0])                }
                | 'false'                     { result = FalseExp.new(val[0])               }
                | 'string'                    { result = StringType.new(val[0])             }
                | 'id'                        { result = Identifier.new(val[0])             }
                | '-' Expression = UMINUS     { result = UnaryMinus.new(val[1])             }
                | 'not' Expression            { result = Negation.new(val[1])               }
                | Expression '*' Expression   { result = Multiplication.new(val[0], val[2]) }
                | Expression '/' Expression   { result = Division.new(val[0], val[2])       }
                | Expression 'div' Expression { result = IntDivision.new(val[0], val[2])    }
                | Expression 'mod' Expression { result = Modulus.new(val[0], val[2])        }
                | Expression '%' Expression   { result = ExactylModulus.new(val[0], val[2]) }
                | Expression '+' Expression   { result = Addition.new(val[0], val[2])       }
                | Expression '-' Expression   { result = Subtraction.new(val[0], val[2])    }
                | Expression '==' Expression  { result = Equivalent.new(val[0], val[2])     }
                | Expression '!=' Expression  { result = Diferent.new(val[0], val[2])       }
                | Expression '<=' Expression  { result = LessOrEqual.new(val[0], val[2])    }
                | Expression '>=' Expression  { result = GreaterOrEqual.new(val[0], val[2]) }
                | Expression '<' Expression   { result = Less.new(val[0], val[2])           }
                | Expression '>' Expression   { result = Greater.new(val[0], val[2])        }
                | Expression 'or' Expression  { result = Disyunction.new(val[0], val[2])    }
                | Expression 'and' Expression { result = Conjunction.new(val[0], val[2])    }
                | '(' Expression ')'          { result = val[1]                             }
    ;

    Datatype:     'boolean' { result = val[0] }
                | 'number'  { result = val[0] }
    ;

    Statement:    Datatype 'id'                { result = Declare.new(val[0], val[1])                       }
                | Datatype 'id' '=' Expression { result = DeclareWithAssignment.new(val[0], val[1], val[3]) }
    ;

    Instruction:  'id' '=' Expression { result = AssignmentInst.new(val[0], val[2]) }
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

    Blocks:       'with' Statements 'do' Instructions 'end'                              { result = WithBlock.new(val[1])  }
                | 'func' 'id' Params '->' Datatype 'begin' Instructions 'end'            { result = BeginBlock.new(val[1]) }
                | 'while' Expression 'do' Instructions 'end'                             { result = BeginBlock.new(val[1]) }
                | 'for' 'num' 'from' 'num' 'to' 'num' 'by' 'num' 'do' Instructions 'end' { result = BeginBlock.new(val[1]) }
                | 'if' Expression 'then' Instructions 'end'                              { result = IfBlock.new(val[1], val[3]) }
                | 'if' Expression 'then' Instructions 'else' Instructions 'end'          { result = IfBlock.new(val[1], val[3]) }
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
