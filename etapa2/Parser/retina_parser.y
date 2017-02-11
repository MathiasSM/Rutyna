####################################################################################################################################
## DESCRIPCIÓN:
####################################################################################################################################

# Código que será compilado con racc para generar el parser del lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las especificaciones dadas para el proyecto del curso
# CI-3725 de la Universidad Simón Bolívar durante el trimestre Enero-Marzo 2017.

####################################################################################################################################
## AUTORES:
####################################################################################################################################

# Carlos Serrada, 13-11347, cserradag96@gmail.com
# Mathias San Miguel, 13-11310, mathiassanmiguel@gmail.com

####################################################################################################################################
## DECLARACIÓN DEL PARSER:
####################################################################################################################################

class Parser
    # Lista de tokens
    token '==' '/=' '>=' '<=' '>' '<' '->' '+' '-' '*' '/' '%' 'mod' 'div' '=' '(' ')' ';' ',' 'not' 'and' 'or' 'true' 'false' 'program' 'end' 'with' 'do' 'while' 'if' 'then' 'else' 'for' 'from' 'by' 'to' 'repeat' 'times' 'func' 'begin' 'return' 'boolean' 'number' 'read' 'write' 'writeln' 'num' 'funid' 'varid' 'str' UMINUS

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
        'program' 'Program'
        'end'     'End'
        'with'    'With'
        'do'      'Do'
        'while'   'While'
        'if'      'If'
        'then'    'Then'
        'else'    'Else'
        'for'     'For'
        'from'    'From'
        'by'      'By'
        'to'      'To'
        'repeat'  'Repeat'
        'times'   'Times'
        'func'    'Function'
        'begin'   'Begin'
        'return'  'Return'

        # Métodos de Entrada/Salida
        'read'    'Read'
        'write'   'Write'
        'writeln' 'WriteLine'

        # Literales e identificadores
        'num'   'NumberLiteral'
        'funid' 'FunctionIdentifier'
        'varid' 'VariableIdentifier'
        'str'   'StringLiteral'

end

#-----------------------------------------------------------------------------------------------------------------------------------
## Reglas de la gramática:
#-----------------------------------------------------------------------------------------------------------------------------------

start Retina

rule
    Expression:   'num'                       { result = SingleNumber.new(val[0])                    }
                | 'true'                      { result = SingleTrue.new(val[0])                      }
                | 'false'                     { result = SingleFalse.new(val[0])                     }
                | 'str'                       { result = SingleString.new(val[0])                    }
                | VarID                       { result = val[0]                                      }
                | FunID                       { result = val[0]                                      }
                | '(' Expression ')'          { result = val[1]                                      }
                | '-' Expression = UMINUS     { result = UnaryMinusOperation.new(val[1])             }
                | 'not' Expression            { result = NegationOperation.new(val[1])               }
                | Expression '*' Expression   { result = MultiplicationOperation.new(val[0], val[2]) }
                | Expression '/' Expression   { result = DivisionOperation.new(val[0], val[2])       }
                | Expression 'div' Expression { result = IntDivisionOperation.new(val[0], val[2])    }
                | Expression 'mod' Expression { result = ModulusOperation.new(val[0], val[2])        }
                | Expression '%' Expression   { result = ExactModulusOperation.new(val[0], val[2])   }
                | Expression '+' Expression   { result = AdditionOperation.new(val[0], val[2])       }
                | Expression '-' Expression   { result = SubtractionOperation.new(val[0], val[2])    }
                | Expression '==' Expression  { result = EquivalentOperation.new(val[0], val[2])     }
                | Expression '/=' Expression  { result = DifferentOperation.new(val[0], val[2])      }
                | Expression '<=' Expression  { result = LessOrEqualOperation.new(val[0], val[2])    }
                | Expression '>=' Expression  { result = GreaterOrEqualOperation.new(val[0], val[2]) }
                | Expression '<' Expression   { result = LessOperation.new(val[0], val[2])           }
                | Expression '>' Expression   { result = GreaterOperation.new(val[0], val[2])        }
                | Expression 'or' Expression  { result = DisjunctionOperation.new(val[0], val[2])    }
                | Expression 'and' Expression { result = ConjunctionOperation.new(val[0], val[2])    }
    ;

    Expressions:  Expression                 { result = ASList.new(val[0])               }
                | Expressions ',' Expression { result = ASList.new(val[2]).joina(val[0]) }
    ;

    VarID:        'varid' { result = VariableName.new(val[0]) }
    ;

    FunID:        'funid' { result = FunctionName.new(val[0]) }
    ;

    Datatype:     'boolean' { result = Type.new(val[0]) }
                | 'number'  { result = Type.new(val[0]) }
    ;

    Statement:    Datatype VarID                { result = SimpleStatement.new(val[0], val[1])             }
                | Datatype VarID '=' Expression { result = AssignmentStatement.new(val[0], val[1], val[3]) }
    ;

    Statements:   Statement ';'            { result = ASList.new(val[0])               }
                | Statements Statement ';' { result = ASList.new(val[1]).joina(val[0]) }
    ;

    Instruction:  Expression                                                                            { val[0]                                                    }
                | VarID '=' Expression                                                                  { result = AssignmentInstruction.new(val[0], val[2])        }
                | FunID '(' Expressions ')'                                                             { result = FunctionCall.new(val[0], val[2])                 }
                | FunID '(' ')'                                                                         { result = FunctionCall.new(val[0], {})                     }
                | 'with' Statements 'do' Instructions 'end'                                             { result = WithBlock.new(val[1], val[3])                    }
                | 'with'  'do' Instructions 'end'                                                       { result = WithBlock.new({}, val[2])                        }
                | 'with'  'do'  'end'                                                                   { result = WithBlock.new({}, {})                            }
                | 'while' Expression 'do' Instructions 'end'                                            { result = WhileBlock.new(val[1], val[3])                   }
                | 'for' VarID 'from' Expression 'to' Expression 'by' Expression 'do' Instructions 'end' { result = ForBlock.new(val[1],val[3],val[5],val[7],val[9]) }
                | 'for' VarID 'from' Expression 'to' Expression 'do' Instructions 'end'                 { result = ForBlock.new(val[1],val[3],val[5],1,     val[7]) }
                | 'if' Expression 'then' Instructions 'end'                                             { result = IfBlock.new(val[1], val[3])                      }
                | 'if' Expression 'then' Instructions 'else' Instructions 'end'                         { result = IfElseBlock.new(val[1], val[3], val[5])          }
                | 'repeat' Expression 'times' Instructions 'end'                                        { result = RepeatBlock.new(val[1], val[3])                  }
                | 'read' VarID                                                                          { result = InputOperation.new(val[1])                       }
                | 'write' Expressions                                                                   { result = OutputOperation.new(val[1])                      }
                | 'writeln' Expressions                                                                 { result = OutputOperation.new(val[1])                      }
    ;

    Instructions: Instruction ';'              { result = ASList.new(val[0])               }
                | Instructions Instruction ';' { result = ASList.new(val[1]).joina(val[0]) }
    ;

    InstructionsR: Instruction ';'              { result = ASList.new(val[0])               }
                | 'return' Expression ';'       { result = ASList.new(val[1])               }
                | InstructionsR Instruction ';' { result = ASList.new(val[1]).joina(val[0]) }
    ;

    Params:       Statement            { result = ASList.new(val[0])               }
                | Params ',' Statement { result = ASList.new(val[2]).joina(val[0]) }
    ;

    Program:      'program' Instructions 'end' { result = ProgramBlock.new(val[1]) }
    ;

    Function:     'func' FunID '(' Params ')' '->' Datatype 'begin' InstructionsR 'end' { result = FunctionStatement.new(val[1], val[3], val[6], val[8]) }
                | 'func' FunID '(' ')' '->' Datatype 'begin' InstructionsR 'end'        { result = FunctionStatement.new(val[1], {}, val[5], val[6])     }
                | 'func' FunID '(' Params ')' 'begin' Instructions 'end'                { result = FunctionStatement.new(val[1], val[3], {}, val[6])     }
                | 'func' FunID '(' ')' 'begin' Instructions 'end'                       { result = FunctionStatement.new(val[1], {}, {}, val[5])         }
    ;

    Functions: Function ';'              { result = ASList.new(val[0])               }
                | Functions Function ';' { result = ASList.new(val[1]).joina(val[0]) }
    ;

    Retina:   Program ';'                { result = ASList.new(val[0])               }
                | Functions Program ';'  { result = ASList.new(val[1]).joina(val[0]) }
    ;

####################################################################################################################################
## Declaración del resto de las clases necesarias para el manejo de parser:
####################################################################################################################################

---- header

require_relative "retina_lexer"  # Importar el lexer de retina
require_relative "retina_ast"    # Importar el AST de retina

# Clase para los errores de sintaxis
class SyntacticError < RuntimeError

    def initialize(tok)
        @token = tok
    end

    def to_s
        "Syntactic error on: #{@token}"
    end
end

---- inner

# Clase para captar los errores y producir una excepcion
# generando una instancia de error de sintaxis
def on_error(id, token, stack)
    raise SyntacticError::new(token)
end

# Clase para obtener el siguiente token reconocido por el lexer
def next_token
    token = @lexer.catch_lexeme
    return [false,false] unless token
    return [token.class,token]
end

# Función para hacer el parse del lexer con el método
# definido por racc
def parse(lexer)
    @yydebug = true
    @lexer = lexer
    @tokens = []
    ast = do_parse
    return ast
end

####################################################################################################################################
## FIN :)
####################################################################################################################################