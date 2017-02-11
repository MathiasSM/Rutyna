class Parser
    # Lista de tokens
    token '==' '/=' '>=' '<=' '>' '<' '->' '+' '-' '*' '/' '%' 'mod' 'div' '=' '(' ')' ';' ',' 'not' 'and' 'or' 'true' 'false' 'program' 'end' 'with' 'do' 'while' 'if' 'then' 'else' 'for' 'from' 'by' 'to' 'repeat' 'times' 'function' 'begin' 'return' 'boolean' 'number' 'openeye' 'closeeye' 'backward' 'forward' 'rotatel' 'rotater' 'setposition' 'arc' 'read' 'write' 'writeline' 'num' 'funid' 'varid' 'str' UMINUS

    # Tabla de presedencia
    prechigh
        right 'not' UMINUS
        left '*' '/' 'div' 'mod' '%'
        left '+' '-'
        noassoc '<=' '>=' '<' '>'
        left '==' '/='
        left 'or'
        left 'and'
    preclow

    # Lista de conversiones de tokens a clases
    convert
        # Tipos
        'boolean' 'Boolean'
        'number'  'Number'

        # Operadores de comparación
        '==' 'Equal'
        '/=' 'NotEqual'
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

    Expression:   'num'                       { result = SingleNumber.new(val[0])               }
                | 'true'                      { result = SingleTrue.new(val[0])                 }
                | 'false'                     { result = SingleFalse.new(val[0])                }
                | 'str'                       { result = SingleString.new(val[0])               }
                | 'varid'                     { result = VariableName.new(val[0])                   }
                | '-' Expression = UMINUS     { result = UnaryMinusOperation.new(val[1])             }
                | 'not' Expression            { result = NegationOperation.new(val[1])               }
                | Expression '*' Expression   { result = MultiplicationOperation.new(val[0], val[2]) }
                | Expression '/' Expression   { result = DivisionOperation.new(val[0], val[2])       }
                | Expression 'div' Expression { result = IntDivisionOperation.new(val[0], val[2])    }
                | Expression 'mod' Expression { result = ModulusOperation.new(val[0], val[2])        }
                | Expression '%' Expression   { result = ExactModulusOperation.new(val[0], val[2]) }
                | Expression '+' Expression   { result = AdditionOperation.new(val[0], val[2])       }
                | Expression '-' Expression   { result = SubtractionOperation.new(val[0], val[2])    }
                | Expression '==' Expression  { result = EquivalentOperation.new(val[0], val[2])     }
                | Expression '/=' Expression  { result = DifferentOperation.new(val[0], val[2])       }
                | Expression '<=' Expression  { result = LessOrEqualOperation.new(val[0], val[2])    }
                | Expression '>=' Expression  { result = GreaterOrEqualOperation.new(val[0], val[2]) }
                | Expression '<' Expression   { result = LessOperation.new(val[0], val[2])           }
                | Expression '>' Expression   { result = GreaterOperation.new(val[0], val[2])        }
                | Expression 'or' Expression  { result = DisjunctionOperation.new(val[0], val[2])    }
                | Expression 'and' Expression { result = ConjunctionOperation.new(val[0], val[2])    }
                | '(' Expression ')'          { result = val[1]                                     }
    ;

    Datatype:     'boolean' { result = val[0] }
                | 'number'  { result = val[0] }
    ;

    Statement:    Datatype 'varid'                      { result = SimpleStatement.new(val[0], val[1])                       }
                | Datatype 'varid' '=' Expression       { result = AssignmentStatement.new(val[0], val[1], val[3])           }
                |  /*Lambda*/                           { }
    ;

    Statements:   Statement ';'                         { result = ASList.new(val[0])             }
                | Statements Statement ';'              { result = ASList.new(val[1]).joina(val[0]) }
    ;

    Instruction:  Expression                                                                                    { val[0] }
                | 'varid' '=' Expression                                                                        { result = AssignmentInstruction.new(val[0], val[2]) }
                | 'with' Statements 'do' Instructions 'end'                                                     { result = WithBlock.new(val[1], val[3])           }
                | 'while' Expression 'do' Instructions 'end'                                                    { result = WhileBlock.new(val[1], val[3]) }
                | 'for' 'varid' 'from' Expression 'to' Expression 'by' Expression 'do' Instructions 'end'       { result = ForBlock.new(val[1],val[3],val[5],val[7],val[8]) }
                | 'for' 'varid' 'from' Expression 'to' Expression 'do' Instructions 'end'                       { result = ForBlock.new(val[1],val[3],val[5],1,     val[8]) }
                | 'if' Expression 'then' Instructions 'end'                                                     { result = IfBlock.new(val[1], val[3])     }
                | 'if' Expression 'then' Instructions 'else' Instructions 'end'                                 { result = IfElseBlock.new(val[1], val[3], val[5]) }
                | 'repeat' Expression 'times' Instructions 'end'                                                { result = RepeatBlock.new(val[1], val[3]) }
                | 'funid' '(' Params ')'                                                                        { result = FunctionName.new(val[0], val[2]) }
                |  /*Lambda*/                           {  }
    ;

    Instructions: Instruction ';'                       { result = ASList.new(val[0])             }
                | Instructions Instruction ';'          { result = ASList.new(val[1]).joina(val[0]) }
    ;

    InstructionsR: Instruction ';'                      { result = ASList.new(val[0])             }
                | 'return' Expression ';'               { result = ASList.new(val[1])        }
                | InstructionsR Instruction ';'         { result = ASList.new(val[1]).joina(val[0]) }
    ;

    Params:       Statement                             { result = ASList.new(val[0])            }
                | Params ',' Statement                  { result = ASList.new(val[2]).joina(val[0]) }
    ;

    Program: 'program' Instructions 'end'               { result = ProgramBlock.new(val[1]) }
    ;

    Function: 'func' 'funid' '(' Params ')' '->' Datatype 'begin' InstructionsR 'end'                       { result = FunctionStatement.new(val[1], val[3], val[6], val[8])       }
                | 'func' 'funid' '(' Params ')' 'begin' Instructions 'end'                                  { result = FunctionStatement.new(val[1], val[3], {}, val[6])       }
    ;

    Functions: Function ';'                             { result = ASList.new(val[0])  }
                | Functions Function ';'                { result = ASList.new(val[1]).joina(val[0]) }

    Retina:   Program ';'                               { result = ASList.new(val[0])  }
                | Functions Program ';'                 { result = ASList.new(val[1]).joina(val[0]) }
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
