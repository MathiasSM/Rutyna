####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# GRAMMAR FILE para el lenguaje Retina. (A ser compilado con RACC)
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las
# especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com



####################################################################################################
## DECLARACIÓN DEL PARSER:
####################################################################################################
class Parser
  # Lista de tokens
  token '==' '/=' '>=' '<=' '>' '<' '->' '+' '-' '*' '/' '%' mod div '=' '(' ')' ';' ',' not and or true false program 'end' with do while if then else for from by to repeat times func begin return boolean number read write writeln NumberLiteral FunctionID VariableID StringLiteral UMINUS

  # Tabla de precedencia
  prechigh
    right not UMINUS
    right '-'
    left '*' '/' div mod '%'
    left '+' '-'
    noassoc '<=' '>=' '<' '>'
    left '==' '/='
    left or
    left and
  preclow

  # Lista de conversiones de tokens a clases
  convert
    # Tipos
    boolean 'Boolean'
    number  'Number'

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
    mod 'Mod'
    div 'Div'

    # Signos
    '=' 'Assignment'
    '(' 'OpenRoundBracket'
    ')' 'CloseRoundBracket'
    ';' 'Semicolon'
    ',' 'Comma'

    # Operadores lógicos
    not 'Not'
    and 'And'
    or  'Or'

    # Constantes booleanas
    true  'True'
    false 'False'

    # Bloques
    program 'Program'
    'end'     'End'
    with    'With'
    do      'Do'
    while   'While'
    if      'If'
    then    'Then'
    else    'Else'
    for     'For'
    from    'From'
    by      'By'
    to      'To'
    repeat  'Repeat'
    times   'Times'
    func    'Function'
    begin   'Begin'
    return  'Return'

    # Métodos de Entrada/Salida
    read    'Read'
    write   'Write'
    writeln 'WriteLine'

    # Literales e identificadores
    NumberLiteral  'NumberLiteral'
    FunctionID     'FunctionIdentifier'
    VariableID     'VariableIdentifier'
    StringLiteral  'StringLiteral'
end

#-----------------------------------------------------------------------------------------------------------------------------------
## Reglas de la gramática:
#-----------------------------------------------------------------------------------------------------------------------------------

start RETINA

rule
  EXPRESSION:   NumberLiteral                                                               { result = Nodo_LitNumber.new( val[0] ) }
              | true                                                                        { result = Nodo_LitBoolean.new( val[0] ) }
              | false                                                                       { result = Nodo_LitBoolean.new( val[0] ) }
              | StringLiteral                                                               { result = Nodo_LitString.new( val[0] ) }
              | VariableID                                                                  { result = Nodo_LlamaVariable.new( val[0] ) }
              | FunctionID '(' EXPRESSIONs ')'                                              { result = Nodo_LlamaFuncion.new( val[0], val[2] ) }
              | FunctionID '(' ')'                                                          { result = Nodo_LlamaFuncion.new( val[0], Nodo_Lista.new() ) }
              | '(' EXPRESSION ')'                                                          { result = val[1] }
              
              | '-' EXPRESSION = UMINUS                                                     { result = Nodo_UMINUS.new( val[1] ) }
              | not EXPRESSION                                                              { result = Nodo_Not.new( val[1] ) }
              
              | EXPRESSION '*' EXPRESSION                                                   { result = Nodo_Multiplicacion.new( val[0], val[2] ) }
              | EXPRESSION '/' EXPRESSION                                                   { result = Nodo_DivisionReal.new( val[0], val[2] ) }
              | EXPRESSION div EXPRESSION                                                   { result = Nodo_DivisionEntera.new( val[0], val[2] ) }
              | EXPRESSION mod EXPRESSION                                                   { result = Nodo_ModuloEntero.new( val[0], val[2] ) }
              | EXPRESSION '%' EXPRESSION                                                   { result = Nodo_ModuloReal.new( val[0], val[2] ) }
              | EXPRESSION '+' EXPRESSION                                                   { result = Nodo_Suma.new( val[0], val[2] ) }
              | EXPRESSION '-' EXPRESSION                                                   { result = Nodo_Resta.new( val[0], val[2] ) }
              
              | EXPRESSION '==' EXPRESSION                                                  { result = Nodo_IgualQue.new(val[0], val[2]) }
              | EXPRESSION '/=' EXPRESSION                                                  { result = Nodo_DiferenteDe.new(val[0], val[2]) }
              
              | EXPRESSION '<=' EXPRESSION                                                  { result = Nodo_MenorIgualQue.new(val[0], val[2]) }
              | EXPRESSION '>=' EXPRESSION                                                  { result = Nodo_MayorIgualQue.new(val[0], val[2]) }
              | EXPRESSION '<' EXPRESSION                                                   { result = Nodo_MenorQue.new( val[0], val[2] ) }
              | EXPRESSION '>' EXPRESSION                                                   { result = Nodo_MayorQue.new( val[0], val[2] ) }
              
              | EXPRESSION or EXPRESSION                                                    { result = Nodo_O.new( val[0], val[2] ) }
              | EXPRESSION and EXPRESSION                                                   { result = Nodo_Y.new( val[0], val[2] ) }
  ;

  EXPRESSIONs:  EXPRESSION                                                                  { result = Nodo_Lista.new( val[0] ) }
              | EXPRESSIONs ',' EXPRESSION                                                  { result = Nodo_Lista.new(val[2]).appendTo( val[0] ) }
  ;

  VARID:        VariableID                                                                  { result = Nodo_VariableNewName.new( val[0] ) }
  ;
  
  VARIDs:       VARID                                                                       { result = Nodo_Lista.new( val[0] ) }
              | VARIDs ',' VARID                                                            { result = Nodo_Lista.new( val[2] ).appendTo( val[0] ) }


  DATATYPE:     boolean                                                                     { result = val[0] }
              | number                                                                      { result = val[0] }
  ;
  
  STATEMENT:    DATATYPE VARIDs                                                             { result = Nodo_DeclaracionMultiple.new(val[0], val[1]) }
              | DATATYPE VARID '=' EXPRESSION                                               { result = Nodo_DeclaracionCompleta.new(val[0], val[1], val[3]) }
  ;

  STATEMENTs:   STATEMENT ';'                                                               { result = Nodo_Lista.new(val[0]) }
              | STATEMENTs STATEMENT ';'                                                    { result = Nodo_Lista.new(val[1]).appendTo(val[0]) }
  ;

  INSTRUCTION:                                                                              { result = Nodo_Nulo.new }
              | VARID '=' EXPRESSION                                                        { result = Nodo_Asignacion.new(              val[0],              val[2] ) }
              | with STATEMENTs do INSTRUCTIONs 'end'                                       { result = Nodo_BloqueWith.new(              val[1],              val[3] ) }
              | with STATEMENTs do 'end'                                                    { result = Nodo_BloqueWith.new(              val[1], Nodo_Lista.new(nil) ) }
              | with  do INSTRUCTIONs 'end'                                                 { result = Nodo_BloqueWith.new( Nodo_Lista.new(nil),              val[2] ) }
              | with  do  'end'                                                             { result = Nodo_BloqueWith.new( Nodo_Lista.new(nil), Nodo_Lista.new(nil) ) }
              | while EXPRESSION do INSTRUCTIONs 'end'                                      { result = Nodo_BloqueWhile.new( val[1], val[3] ) }
              | for VARID from EXPRESSION to EXPRESSION by EXPRESSION do INSTRUCTIONs 'end' { result = Nodo_BloqueFor.new( val[1], val[3], val[5],                  val[7],              val[9] ) }
              | for VARID from EXPRESSION to EXPRESSION by EXPRESSION do 'end'              { result = Nodo_BloqueFor.new( val[1], val[3], val[5],                  val[7], Nodo_Lista.new(nil) ) }
              | for VARID from EXPRESSION to EXPRESSION do INSTRUCTIONs 'end'               { result = Nodo_BloqueFor.new( val[1], val[3], val[5], Nodo_LitNumber.new( 1 ),              val[7] ) }
              | for VARID from EXPRESSION to EXPRESSION do 'end'                            { result = Nodo_BloqueFor.new( val[1], val[3], val[5], Nodo_LitNumber.new( 1 ), Nodo_Lista.new(nil) ) }
              | if EXPRESSION then INSTRUCTIONs 'end'                                       { result = Nodo_BloqueIfElse.new( val[1],              val[3], Nodo_Lista.new(nil) ) }
              | if EXPRESSION then 'end'                                                    { result = Nodo_BloqueIfElse.new( val[1], Nodo_Lista.new(nil), Nodo_Lista.new(nil) ) }
              | if EXPRESSION then INSTRUCTIONs else INSTRUCTIONs 'end'                     { result = Nodo_BloqueIfElse.new( val[1],              val[3],              val[5] ) }
              | if EXPRESSION then INSTRUCTIONs else 'end'                                  { result = Nodo_BloqueIfElse.new( val[1],              val[3], Nodo_Lista.new(nil) ) }
              | if EXPRESSION then else INSTRUCTIONs 'end'                                  { result = Nodo_BloqueIfElse.new( val[1], Nodo_Lista.new(nil),              val[4] ) }
              | if EXPRESSION then else 'end'                                               { result = Nodo_BloqueIfElse.new( val[1], Nodo_Lista.new(nil), Nodo_Lista.new(nil) ) }
              | repeat EXPRESSION times INSTRUCTIONs 'end'                                  { result = Nodo_BloqueRepeat.new( val[1],             val[3]  ) }
              | repeat EXPRESSION times 'end'                                               { result = Nodo_BloqueRepeat.new( val[1], Nodo_Lista.new(nil) ) }
              | read VariableID                                                             { result = Nodo_Read.new( val[1] ) }
              | write EXPRESSIONs                                                           { result = Nodo_Write.new( val[1],   '' ) }
              | writeln EXPRESSIONs                                                         { result = Nodo_Write.new( val[1], '\n' ) }
              | return EXPRESSION                                                           { result = Nodo_Return.new( val[1] ) }
              | FunctionID '(' EXPRESSIONs ')'                                              { result = Nodo_LlamaFuncion.new( val[0],              val[2] ) }
              | FunctionID '(' ')'                                                          { result = Nodo_LlamaFuncion.new( val[0], Nodo_Lista.new(nil) ) }
  ;

  INSTRUCTIONs: INSTRUCTION ';'                                                             { result = Nodo_Lista.new(val[0]) }
              | INSTRUCTIONs INSTRUCTION ';'                                                { result = Nodo_Lista.new(val[1]).appendTo(val[0]) }
  ;

  PARAMS:       DATATYPE VARID                                                              { result = Nodo_Lista.new( Nodo_DeclaracionSimple.new( val[0], val[1] ) ) }
              | PARAMS ',' DATATYPE VARID                                                   { result = Nodo_Lista.new( Nodo_DeclaracionSimple.new( val[2], val[3] ) ).appendTo( val[0] ) }
  ;

  PROGRAM:      program INSTRUCTIONs 'end'                                                  { result = Nodo_BloqueProgram.new( val[1] ) }
              | program 'end'                                                               { result = Nodo_BloqueProgram.new(    nil ) }
  ;
  
  BEGINEND:     begin INSTRUCTIONs 'end'                                                    { result =                val[1] }
              | begin 'end'                                                                 { result = Nodo_Lista.new( nil ) }
  ;
  
  FUNID:        FunctionID                                                                  { result = Nodo_FunctionNewName.new( val[0] ) }
  ;
  
  FUNCTION:     func FUNID '(' PARAMS ')' '->' DATATYPE BEGINEND                            { result = Nodo_NewFunctionBody.new( val[1],                val[3],                val[6], val[7] ) }
              | func FUNID '(' ')' '->' DATATYPE BEGINEND                                   { result = Nodo_NewFunctionBody.new( val[1], Nodo_Lista.new( nil ),                val[5], val[6] ) }
              | func FUNID '(' PARAMS ')' BEGINEND                                          { result = Nodo_NewFunctionBody.new( val[1],                val[3], Nodo_Lista.new( nil ), val[5] ) }
              | func FUNID '(' ')' BEGINEND                                                 { result = Nodo_NewFunctionBody.new( val[1], Nodo_Lista.new( nil ), Nodo_Lista.new( nil ), val[4] ) }
  ;

  FUNCTIONs: FUNCTION ';'                                                                   { result = Nodo_Lista.new( val[0] ) }
              | FUNCTIONs FUNCTION ';'                                                      { result = Nodo_Lista.new( val[1] ).appendTo( val[0] ) }
  ;

  RETINA:   PROGRAM ';'                                                                     { result = Nodo_Lista.new( val[0] ) }
              | FUNCTIONs PROGRAM ';'                                                       { result = Nodo_Lista.new( val[1] ).appendTo( val[0] ) }
  ;

####################################################################################################
## USER BLOCKS
####################################################################################################
---- header
require_relative "retina_lexer"  # Importar el lexer de retina
require_relative "retina_ast"    # Importar el AST de retina

# CLASE de ERROR DE SINTÁXISz
#=======================================
class SyntacticError < RuntimeError
  def initialize token
    @token = token
  end

  def to_s
    if false
      "Error de Sintáxis: linea #{@token.row}, columna #{@token.col}: token inesperado"
    else
      "Error de Sintáxis: linea #{@token.row}, columna #{@token.col}: token inesperado \'#{@token.to_str}\'"
    end
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

# Función para hacer el parse del lexer con el método definido por racc
def parse(lexer)
  @yydebug = true
  @lexer = lexer
  @tokens = []
  ast = do_parse
  return ast
end
