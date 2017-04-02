####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# CLASE(S) para el AST del lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las
# especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com


####################################################################################################
## Manejo de ERRORES DE CONTEXTO
####################################################################################################

class ContextError < RuntimeError
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end
  
  def to_s
    "Error de contexto: #{@mensaje} (#{@nodo.class.to_s[5..-1]} en línea #{@nodo.row})"
  end
end

####################################################################################################
## Manejo de VALORES DE RETORNO
####################################################################################################

class ReturnValueE < StandardError
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end
end



####################################################################################################
## Abstract Syntax Tree
####################################################################################################

class AST
  def initialize program, functions=nil
    $tl = TableList.new
    @program = program
    @functions = functions
    @functions.recorrer if not @functions.nil?
  end
  def execute
    begin
      $executing = true
      @program.recorrer
    ensure
      $executing = false
    end
  end
end
  


####################################################################################################
## Abstract Syntax NODES
####################################################################################################

class NodoAST
  def recorrer; end
  def place r; @lugar = r; end
  def row; return @lugar; end
end

class Nodo_Nulo < NodoAST; end



####################################################################################################
## Tipos de Nodos
####################################################################################################

# Nodo LISTA de cosas
# ======================
# (instrucciones, variables, etc. Devuelve la lista al recorrer)
class Nodo_Lista < NodoAST
  attr_accessor :lista
  
  def initialize k=nil
    k.nil? ? @lista=[] : @lista=[k];
  end
  
  def appendTo nl=nil
    return self if nl.nil?
    @lista = nl.lista + @lista
    return self
  end
  
  def recorrer
    cosas = []
    @lista.each do |a|
      cosas.push a.recorrer if not a.nil?
    end
    return nil, cosas
  end
end



# Nodos de LITERALES
# ======================
# (udevuelven el literal al recorrer)
class Nodo_Literal < NodoAST
  def initialize literal
    @literal = literal
  end
end

class Nodo_LitNumber < Nodo_Literal;  def recorrer; return "number",   @literal.to_str.to_i;        end; end
class Nodo_LitBoolean < Nodo_Literal; def recorrer; return "boolean", (@literal.to_str == "true");  end; end
class Nodo_LitString < Nodo_Literal;  def recorrer; return "string",   @literal.to_str;             end; end


# Nodos de OPERACIONES (SUPER CLASES)
# ======================
# (unarios y binarios)
class Nodo_OpeUnaria < NodoAST
  def initialize op
    @op = op
  end
end

class Nodo_OpeBinaria < NodoAST
  def initialize op1, op2
    @op1, @op2 = op1, op2
  end
end


# Nodos de OPERACIONES UNARIAS
# ======================
class Nodo_UMINUS < Nodo_OpeUnaria
  def recorrer
    raise (ContextError.new(self, "Operador nulo")) if @op.nil?
    t, v = @op.recorrer
    raise (ContextError.new(self, "Tipo de operador no es 'number' (Es '#{t}')")) if t!="number"
    return "number", -v
  end
end

class Nodo_Not < Nodo_OpeUnaria
  def recorrer
    raise (ContextError.new(self, "Operador nulo")) if @op.nil?
    t, v = @op.recorrer
    raise (ContextError.new(self, "Tipo de #{@op} no es 'boolean' (Es '#{t}')")) if t!="boolean"
    return "boolean", (not v)
  end
end


# Nodos de OPERACIONES BINARIAS ( NUMBER x NUMBER -> NUMBER )
# ==============================================
class Nodo_Suma < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2 (Es '#{t1}')}')")) if t2!="number"
    return "number", (v1+v2)
  end
end

class Nodo_Resta < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "number", (v1-v2)
  end
end

class Nodo_Multiplicacion < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "number", (v1*v2)
  end
end

class Nodo_DivisionReal < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2==0
    return "number", (v1/v2)
  end
end

class Nodo_DivisionEntera < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2==0
    return "number", (v1/v2)
  end
end

class Nodo_ModuloEntero < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2==0
    return "number", (v1%v2)
  end
end

class Nodo_ModuloReal < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2==0
    return "number", (v1%v2)
  end
end


# Nodos de OPERACIONES BINARIAS ( NUMBER x NUMBER -> BOOLEAN )
# ==============================================
class Nodo_MenorQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1<v2)
  end
end

class Nodo_MayorQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1>v2)
  end
end

class Nodo_MenorIgualQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1<=v2)
  end
end

class Nodo_MayorIgualQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1>=v2)
  end
end


# Nodos de OPERACIONES BINARIAS ( BOOLEAN x BOOLEAN -> BOOLEAN )
# ==============================================
class Nodo_Y < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'boolean' (Es '#{t1}')")) if t1!="boolean"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'boolean' (Es '#{t2}')")) if t2!="boolean"
    return "boolean", (v1 and v2)
  end
end

class Nodo_O < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "INTERPRETADOR, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'boolean'")) if t1!="boolean"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'boolean'")) if t2!="boolean"
    return "boolean", (v1 or v2)
  end
end


# Nodos de OPERACIONES BINARIAS ( num/bool x num/bool -> BOOLEAN )
# ==============================================
class Nodo_IgualQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de ambos operadores difiere")) if t1!=t2
    return "boolean", (v1==v2)
  end
end

class Nodo_DiferenteDe < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de ambos operadores difiere")) if t1!=t2
    return "boolean", (v1!=v2)
  end
end


# Nodos de INSTRUCCIONES SIMPLES
# ==============================================
class Nodo_Asignacion < NodoAST
  def initialize quien, conque
    @quien, @conque = quien, conque
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @quien.nil? or @conque.nil?
    t1, v1 = $tl.var_exists? @quien.to_str
    t2, v2 = @conque.recorrer
    raise (ContextError.new(self, "Tipo de variable difiere del tipo de la expresión (#{t1} != #{t2})")) if t1!=t2
    # TODO Setear el nuevo valor de la variable de la tabla correspondiente
    return t1, v2
  end
end

class Nodo_Return < NodoAST
  def initialize que
    @que = que
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @que.nil?
    ret = @que.recorrer
    raise (ReturnValueE.new(ret[1])) if $executing# Lanza el return al controlador de la función
  end
end


# Nodos de INSTRUCCIONES DE IO
# ==============================================
class Nodo_Read < NodoAST
  def initialize que
    @que = que
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @que.nil?
    cosa = $tl.var_exists? @que.recorrer
    #i = gets
    # TODO set value of symbol COSA to i.to_type
    return nil, "READ"
  end
end

class Nodo_Write < NodoAST
  def initialize que, sep
    @que = que
    @sep = sep
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @que.nil?
    cosas = @que.recorrer
    cosas.each do |cosa|
      print cosa[1] if not cosa.nil?
    end
    print @sep
    return nil, "WRITE"
  end
end


# Nodos de BUSQUEDAS DIRECTAS EN TABLAS
# ==============================================
class Nodo_LlamaFuncion < NodoAST
  def initialize name, args
    @name, @args = name.to_str, args
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @name.nil? or @args.nil?
    raise (ContextError.new(self, "Función '#{@name}' no ha sido declarada")) if not ($tl.fun_exists? @name)[0]
    args = @args.recorrer
    return $tl.exec_fun(@name, args)
  end
end

class Nodo_LlamaVariable < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    raise (ContextError.new(self, "Variable '#{@name}' no ha sido declarada en este scope")) if not $tl.var_exists? @name
    return $tl.var_exists? @name
  end
end

class Nodo_FunctionNewName < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    raise (ContextError.new(self, "Funcion '#{@name}' ya ha sido declarada en este scope")) if ($tl.fun_exists? @name)[0]
    return @name
  end
end

class Nodo_VariableNewName < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    raise (ContextError.new(self, "Variable '#{@name}' ya ha sido declarada en este scope")) if $tl.var_exists? @name
    return @name
  end
end


# Nodos de DECLARACIONES
# ==============================================
class Nodo_DeclaracionSimple < NodoAST
  def initialize tipo, varid
    @tipo = tipo.to_str
    @varid = varid
  end
  
  def recorrer
    v = @tipo == "number" ? 0 : false
    nombre = @varid.recorrer.to_str
    $tl.push_var(nombre, @tipo, v)
    return @tipo, nombre
  end
end

class Nodo_DeclaracionMultiple < NodoAST
  def initialize tipo, varids
    @tipo = tipo.to_str
    @varids = varids
  end
  
  def recorrer
    ret = []
    nombres = @varid.recorrer if not @varid.nil?
    v = @tipo == "number" ? 0 : false
    nombres.each do |nombre|
      nombre = @varid.recorrer.to_str
      $tl.push_var(nombre, @tipo, v)
      ret.push( [@tipo, nombre] )
    end
    return ret
  end
end

class Nodo_DeclaracionCompleta < NodoAST
  def initialize tipo, quien, que
    @tipo = tipo.to_str
    @quien = quien
    @que = que
  end
  
  def recorrer
    nombre = @quien.recorrer.to_str
    valor = @que.recorrer[1]
    $tl.push_var(nombre, @tipo, valor)
    return @tipo, nombre
  end
end


# Nodos de BLOQUES
# ==============================================

class Nodo_BloqueRepeat < NodoAST
  def initialize t, i
    @times = t
    @instructions = i
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @times.nil? or @instructions.nil?
    t,v = @times.recorrer
    v = v.to_i
    raise (ContextError.new(self, "Tipo de expresión no es 'number' en el número de pasos (Es #{t})")) if t!="number"
    raise (ContextError.new(self, "Número de pasos negativo")) if v<0
    while v>0
      @instructions.recorrer
      v-=1
    end
  end
end

class Nodo_BloqueWhile < NodoAST
  def initialize e, i
    @expression = e
    @instructions = i
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @expression.nil? or @instructions.nil?
    t,v = @expression.recorrer
    raise (ContextError.new(self, "Tipo de expresión no es 'boolean' (Es #{t})")) if t!="boolean"
    can = (v=="true")
    while can
      @instructions.recorrer
      can = @expression.recorrer[1]
    end
  end
end

class Nodo_BloqueIfElse < NodoAST
  def initialize i, t, e
    @if = i
    @then = t
    @else = e
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @if.nil? or @then.nil? or @else.nil?
    t,v = @if.recorrer
    raise (ContextError.new(self, "Tipo de expresión evaluada por el IF no es 'boolean' (Es #{t})")) if t!="boolean"
    if v == "true"; @then.recorrer
    else;           @else.recorrer
    end
  end
end

class Nodo_Scope < NodoAST
  def recorrer
    $tl.open_scope
    self.recorrer_body
    $tl.close_scope
  end
  def recorrer_body; end
end

class Nodo_BloqueFor < Nodo_Scope
  def initialize it, ini, fin, paso, instr
    @it = it.to_str
    @ini = ini
    @fin = fin
    @paso = paso
    @instr = instr
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @it.nil? or @ini.nil? or @fin.nil? or @paso.nil? or @instr.nil?
    
    $tl.push_var(@it, "number")
    
    ti, vi = @ini.recorrer
    raise (ContextError.new(self, "Tipo de expresión de inicio no es 'number' (Es #{t})")) if ti!="number"
    tf, vf = @fin.recorrer
    raise (ContextError.new(self, "Tipo de expresión de parada no es 'number' (Es #{t})")) if tf!="number"
    
    i,f,paso = vi.to_s.to_i, vf.to_s.to_i, @paso.to_s.to_i
    while i<f
      # Set variable iterador en tabla to value i
      @instr.recorrer
      i+=paso
    end
  end
end

class Nodo_BloqueWith < Nodo_Scope
  def initialize vs, is
    @variables, @instructions = vs, is
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @variables.nil? or @instructions.nil?
    @variables.recorrer
    @instructions.recorrer
  end
end

class Nodo_NewFunctionBody < NodoAST
  def initialize id, params, tipo, instr
    @id = id
    @params = params
    @tipo = tipo
    @instr = instr
  end

  def recorrer
    puts "hi"
    nombre = @id.recorrer
    parametros = @params.recorrer
    @instr.recorrer
    puts "pushing"
    $tl.push_fun(nombre, @tipo, self)
  end
 
  def execute args
    parametros = @params.recorrer # Esto mete los parámetros al symtable
    # Cambiar los valores de los parametros en la symtable
    $tl.push_fun(nombre, @tipo, self)
    begin
      @instr.recorrer
    rescue ReturnValueE => e
      return e
    end
    return nil
  end
end

class Nodo_BloqueProgram < NodoAST
  def initialize is
    @instructions = is
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @instructions.nil?
    @instructions.recorrer
  end
end
  
