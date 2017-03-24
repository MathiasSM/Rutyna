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
## TABLA DE SIMBOLOS
####################################################################################################

# SIMBOLOS
# =====================
class VarSymbol
  attr_accessor :name, :type, :value
  
  def initialize name, type=nil, value=nil
    @name = name
    @type = type
    @value = value
  end
end

class FunSymbol < VarSymbol; end  # Se utiliza el atributo .value para el cuerpo de la función
  
  
# TABLA
# =====================
class SymbolTable
  attr_accessor :table
  
  def initialize
    @table
  end
end


# LISTA DE TABLAS (mayor índice == scope más interno)
# =====================
class TableList
  attr_accessor :meta
  
  def initialize
    @varlist = [SymbolTable.new()]  # Lista de tablas de VarSymbols
    @funtable = SymbolTable.new()   # Una única tabla de FunSymbols
  end
  
  def var_exists? symbol_name
    scope_dist = 0
    @varlist.reverse.each do |scope|
      scope.table.each do |symbol|
        if symbol.name == symbol_name
          return scope_dist, (symbol.type), (symbol.value)
        end
      end
      scope_dist += 1
    end
    return -1, "None", 0 # Doesn't exist? Return these
  end
  
  def fun_exists? symbol_name
    @funtable.each do |function|
      if function.name == symbol_name
        return 1, function.type
      end
    end
    return 0, ""
  end
  
  def exec_fun symbol_name
    @funtable.each do |function|
      if function.name == symbol_name
        # Execute here, we asume it exists
      end
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
  def recorrer
    return self.class.const_get(:Tipo), @literal.to_s
  end
end

class Nodo_LitNumber < Nodo_Literal;  Tipo = "number"; end
class Nodo_LitBoolean < Nodo_Literal; Tipo = "boolean";  end
class Nodo_LitString < Nodo_Literal;  Tipo = "string";  end


# Nodos de OPERACIONES (SUPER CLASES)
# ======================
# (unarios y binarios)
class Nodo_OpeUnaria < NodoAST
  def initialize op
    @op = op
  end
  def recorrer; return nil, @op; end     # Comportamiento por defecto
end

class Nodo_OpeBinaria < NodoAST
  def initialize op1, op2
    @op1, @op2 = op1, op2
  end
  def recorrer; return nil, @op1; end    # Comportamiento por defecto
end


# Nodos de OPERACIONES UNARIAS
# ======================
class Nodo_UMINUS < Nodo_OpeUnaria
  def recorrer
    raise (ContextError.new(self, "Operador nulo")) if @op.nil?
    t, v = @op.recorrer
    raise (ContextError.new(self, "Tipo de operador no es 'number'")) if t!="number"
    return t, -v
  end
end

class Nodo_Not < Nodo_OpeUnaria
  def recorrer
    raise (ContextError.new(self, "Operador nulo")) if @op.nil?
    t, v = @op.recorrer
    raise (ContextError.new(self, "Tipo de #{@op} no es 'boolean'")) if t!="boolean"
    return t, (not v)
  end
end


# Nodos de OPERACIONES BINARIAS ( NUMBER x NUMBER -> NUMBER )
# ==============================================
class Nodo_Suma < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1+v2)
  end
end

class Nodo_Resta < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1-v2)
  end
end

class Nodo_Multiplicacion < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1*v2)
  end
end

class Nodo_DivisionReal < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1/v2)
  end
end

class Nodo_DivisionEntera < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1/v2)
  end
end

class Nodo_ModuloEntero < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "number", (v1%v2)
  end
end

class Nodo_ModuloReal < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
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
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "boolean", (v1<v2)
  end
end

class Nodo_MayorQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "boolean", (v1>v2)
  end
end

class Nodo_MenorIgualQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number'")) if t2!="number"
    return "boolean", (v1<=v2)
  end
end

class Nodo_MayorIgualQue < Nodo_OpeBinaria
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number'")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo no es 'number'")) if t2!="number"
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
    raise (ContextError.new(self, "Tipo de primer operador no es 'boolean'")) if t1!="boolean"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'boolean'")) if t2!="boolean"
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
    t1, v1 = @quien.recorrer
    t2, v2 = @conque.recorrer
    raise (ContextError.new(self, "Tipo de variable difiere del tipo de la expresión")) if t1!=t2
    # Setear el nuevo valor de la variable de la tabla correspondiente
    return t1, v2
  end
end

class Nodo_Return < NodoAST
  def initialize que
    @que = que
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @que.nil?
    # Debería lanzarle el return value a alguien PERO D= no sé como
    return @que.recorrer
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
    cosa = @que
    #i = gets
    # set value of symbol COSA to i.to_type
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
    @name, @args = name, args
  end
  def recorrer
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @name.nil? or @args.nil?
    # Verificar si existe funcion
    #return @name.ejecutar args  # ???
    return "tipo", ""
  end
end

class Nodo_LlamaVariable < NodoAST
  def initialize name
    @name = name
  end
  def recorrer
    # Verificar si existe variable
    #return @name.buscar  # ???
    return "tipo", ""
  end
end

class Nodo_FunctionNewName < NodoAST
  def initialize name
    @name = name
  end
  def recorrer
    # Verificar si existe, error si es así
    # Devuelve t, v donde v es nombre de funcion
    return ""
  end
end

class Nodo_VariableNewName < NodoAST
  def initialize name
    @name = name
  end
  def recorrer
    # Verificar si existe, error si es así
    # Devuelve t, v donde v es nombre de variable
    return ""
  end
end


# Nodos de DECLARACIONES
# ==============================================
class Nodo_DeclaracionSimple < NodoAST
  def initialize tipo, varid
    @tipo = tipo
    @varid = varid
  end
  
  def recorrer
    nombre = @varid.recorrer
    # Añadir variable a tabla con tippo @tipo (es un string)
    
    #PORSIA
    # if @left.to_str == "number"
    #   v = 0
    # else
    #   v = false
    # end
    # $stt.meta[-1].table += [Row.new(@right.to_str, @left.to_str, v)]
    # $stt.meta[-1].table[-1].print_row indent
  end
end

class Nodo_DeclaracionMultiple < NodoAST
  def initialize tipo, varids
    @tipo = tipo
    @varids = varids
  end
  
  def recorrer
    nombres = @varid.recorrer if not @varid.nil?
    # Añadir variables a tabla con tipo @tipo (es un string)
    # @varid es tipo Nodo_Lista y al recorrer devuelve [blah,blah]
    
    #PORSIA
    # if @left.to_str == "number"
    #   v = 0
    # else
    #   v = false
    # end
    # $stt.meta[-1].table += [Row.new(@right.to_str, @left.to_str, v)]
    # $stt.meta[-1].table[-1].print_row indent
  end
end

class Nodo_DeclaracionCompleta < NodoAST
  def initialize tipo, quien, que
    @tipo = tipo
    @quien = quien
    @que = que
  end
  
  def recorrer
    nombre = @quien.recorrer
    valor = @que.recorrer
    
    # Añadir variable a tabla con tipo @tipo (es un string) y valor valor
    # nombre es string, tambien
    
    #PORSIA
    # if @left.to_str == "number"
    #   v = 0
    # else
    #   v = false
    # end
    # $stt.meta[-1].table += [Row.new(@right.to_str, @left.to_str, v)]
    # $stt.meta[-1].table[-1].print_row indent
  end
end

class Nodo_NewFunctionBody < NodoAST
  def initialize id, param, type, instr
    @id = id
    @param = param
    @type = type
    @instr = instr
  end

  def recorrer
    nombre = @id.recorrer
    parametros = @param.recorrer
    # Añadir funcion a tabla de simbolos.
    # Verificar que interno está todo bien.
    # Guardar de alguna forma las instrucciones para cuando sea llamada
  end
end


# Nodos de BLOQUES
# ==============================================
class Nodo_Bloque < NodoAST
  def recorrer
    #abrir_scope
    self.recorrer_body
    #cerrar_scope
    return nil, nil
  end
  def recorrer_body; end
end

class Nodo_BloqueRepeat < Nodo_Bloque
  def initialize t, i
    @times = t
    @instructions = i
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @times.nil? or @instructions.nil?
    t,v = @times.recorrer
    v = v.to_i
    raise (ContextError.new(self, "Tipo de expresión no es 'number' en el número de pasos")) if t!="number"
    raise (ContextError.new(self, "Número de pasos negativo")) if v<0
    while v>0
      @instructions.recorrer
      v-=1
    end
  end
end

class Nodo_BloqueWhile < Nodo_Bloque
  def initialize e, i
    @expression = e
    @instructions = i
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @expression.nil? or @instructions.nil?
    t,v = @expression.recorrer
    raise (ContextError.new(self, "Tipo de expresión no es 'boolean'")) if t!="boolean"
    can = (v=="true")
    while can
      @instructions.recorrer
      can = @expression.recorrer[1]
    end
  end
end

class Nodo_BloqueIfElse < Nodo_Bloque
  def initialize i, t, e
    @if = i
    @then = t
    @else = e
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @if.nil? or @then.nil? or @else.nil?
    t,v = @if.recorrer
    raise (ContextError.new(self, "Tipo de expresión evaluada por el IF no es 'boolean'")) if t!="boolean"
    if v == "true"
      @then.recorrer
    else
      @else.recorrer
    end
  end
end

class Nodo_BloqueFor < Nodo_Bloque
  def initialize it, ini, fin, paso, instr
    @it = it
    @ini = ini
    @fin = fin
    @paso = paso
    @instr = instr
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @it.nil? or @ini.nil? or @fin.nil? or @paso.nil? or @instr.nil?
    iterador = @it.recorrer
    
    ti, vi = @ini.recorrer
    raise (ContextError.new(self, "Tipo de expresión de inicio no es 'number'")) if ti!="number"
    tf, vf = @fin.recorrer
    raise (ContextError.new(self, "Tipo de expresión de parada no es 'number'")) if tf!="number"
    
    i,f,paso = vi.to_i, vf.to_i, @paso.to_i
    while i<f
      # Set variable iterador en tabla to value i
      @instr.recorrer
      i+=paso
    end
  end
end

class Nodo_BloqueWith < Nodo_Bloque
  def initialize vs, is
    @variables, @instructions = vs, is
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @variables.nil? or @instructions.nil?
    @variables.recorrer
    @instructions.recorrer
  end
end

class Nodo_BloqueProgram < Nodo_Bloque
  def initialize is
    @instructions = is
  end
  def recorrer_body
    raise (ContextError.new(self, "Error del interpretador, valor nulo")) if @instructions.nil?
    @instructions.recorrer
  end
end
  
