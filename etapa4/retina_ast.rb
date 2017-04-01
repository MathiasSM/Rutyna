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
## Manejo de ERRORES DE CONTEXTO y posibles errores del INTERPRETE
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

class InterpreterError < RuntimeError
  def initialize nodo, mensaje=""
    @nodo = nodo
    @mensaje = mensaje
  end

  def to_s
    "Error del Interpretador (bug): #{@mensaje} (#{@nodo.class.to_s[5..-1]} con línea #{@nodo.row})"
  end
end

####################################################################################################
## Manejo de VALORES DE RETORNO
####################################################################################################

class ReturnValueE < StandardError
  def initialize nodo, tipo="number", valor=nil
    @nodo = nodo
    @tipo = tipo
    @valor = valor
  end
  
  def eval
    return [@tipo, @valor]
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
## Abstract Syntax Tree
####################################################################################################

# Clase para el AST
# ======================
# Define variable global para Tabla de Símbolos
# Recibe program y functions, hace un recorrido sintáctico/contextual de las funciones
class AST < NodoAST
  def initialize program, functions=nil
    $tl = TableList.new
    @program = program
    @functions = functions
    @functions.recorrer if not @functions.nil?
  end
  def execute
    begin
      puts "\n===============  TODO PARECE NORMAL ALLÁ ARRIBA ================\n" if $debug
      $executing = true
      @program.recorrer
    ensure
      $executing = false
    end
  end
end



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
    if nl.nil?; return self; end
    @lista = nl.lista + @lista
    return self
  end

  def recorrer
    puts "Recorriendo #{self.class}" if $debug
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

class Nodo_LitNumber < Nodo_Literal
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    return "number",   @literal.to_f
  end
end
class Nodo_LitBoolean < Nodo_Literal
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    return "boolean", (@literal.to_str == "true")
  end
end
class Nodo_LitString < Nodo_Literal
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    return "string",   @literal.to_str[1..-2]
  end
end


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
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Operador nulo")) if @op.nil?
    t, v = @op.recorrer
    raise (ContextError.new(self, "Tipo de operador no es 'number' (Es '#{t}')")) if t!="number"
    return "number", -v
  end
end

class Nodo_Not < Nodo_OpeUnaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "number", (v1+v2)
  end
end

class Nodo_Resta < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2.abs<=0.00000000001
    return "number", (v1.fdiv(v2))
  end
end

class Nodo_DivisionEntera < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2.abs<=0.00000000001
    return "number", (v1.div(v2)).to_f
  end
end

class Nodo_ModuloEntero < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Algún operador nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2.abs<=0.00000000001
    return "number", (v1.to_int % v2.to_int).to_f
  end
end

class Nodo_ModuloReal < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    raise (ContextError.new(self, "División por cero")) if v2.abs<=0.00000000001
    return "number", (v1%v2)
  end
end


# Nodos de OPERACIONES BINARIAS ( NUMBER x NUMBER -> BOOLEAN )
# ==============================================
class Nodo_MenorQue < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1<v2)
  end
end

class Nodo_MayorQue < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1>v2)
  end
end

class Nodo_MenorIgualQue < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'number' (Es '#{t1}')")) if t1!="number"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'number' (Es '#{t2}')")) if t2!="number"
    return "boolean", (v1<=v2)
  end
end

class Nodo_MayorIgualQue < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de primer operador no es 'boolean' (Es '#{t1}')")) if t1!="boolean"
    raise (ContextError.new(self, "Tipo de segundo operador no es 'boolean' (Es '#{t2}')")) if t2!="boolean"
    return "boolean", (v1 and v2)
  end
end

class Nodo_O < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
    t1, v1 = @op1.recorrer
    t2, v2 = @op2.recorrer
    raise (ContextError.new(self, "Tipo de ambos operadores difiere")) if t1!=t2
    return "boolean", (v1==v2)
  end
end

class Nodo_DiferenteDe < Nodo_OpeBinaria
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @op1.nil? or @op2.nil?
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
    @quien, @conque = quien.to_str, conque
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @quien.nil? or @conque.nil?
    t1, v1 = $tl.var_exists? @quien
    t2, v2 = @conque.recorrer
    raise (ContextError.new(self, "Tipo de variable difiere del tipo de la expresión (#{t1} != #{t2})")) if t1!=t2
    $tl.var_mod(@quien, v2)
    return t1, v2
  end
end

class Nodo_Return < NodoAST
  def initialize que
    @que = que
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @que.nil?
    ret = @que.recorrer
    #puts "HEY: "+ret.to_s
    raise (ReturnValueE.new(self,ret[0],ret[1])) if $executing # Lanza el return al controlador de la función
  end
end


# Nodos de INSTRUCCIONES DE IO
# ==============================================
class Nodo_Read < NodoAST
  def initialize que
    @que = que.to_str
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @que.nil?
    cosa = $tl.var_exists? @que
    if cosa==false
      raise (ContextError.new(self, "Variable '#{@que}' no ha sido declarada en este scope"))
    end
    begin
      i = STDIN.gets.chomp
      if cosa[0]=="boolean"
        i = i=="true"
      else
        i = i.to_f
      end
      $tl.var_mod(@que, i)
    rescue Exception
      raise (ContextError.new(self, "No se pudo interpretar '#{i}' como '#{cosa[0]}'"))
    end
    return nil, "READ"
  end
end

class Nodo_Write < NodoAST
  def initialize que, sep
    @que = que
    @sep = sep
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @que.nil?
    cosas = @que.recorrer[1]
    cosas.each do |cosa|
      print cosa[1]
    end
    print @sep
    STDOUT.flush
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
    puts "Recorriendo #{self.class}: #{@name}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @name.nil? or @args.nil?
    raise (ContextError.new(self, "Función '#{@name}' no ha sido declarada")) if not ($tl.fun_exists? @name)[0]
    args = @args.recorrer[1]
    ret = $tl.exec_fun(@name, args)
    puts "Recorriendo / #{self.class}" if $debug
    return ret
  end
end

class Nodo_LlamaVariable < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Variable '#{@name}' no ha sido declarada en este scope")) if not $tl.var_exists? @name
    return $tl.var_exists? @name
  end
end

class Nodo_FunctionNewName < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (ContextError.new(self, "Funcion '#{@name}' ya ha sido declarada en este scope")) if ($tl.fun_exists? @name)[0]
    return @name
  end
  def to_str; return @name; end
end

class Nodo_VariableNewName < NodoAST
  def initialize name
    @name = name.to_str
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    #raise (ContextError.new(self, "Variable '#{@name}' ya ha sido declarada en este scope")) if $tl.var_exists? @name
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
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
    ret = []
    nombres = @varids.recorrer[1] if not @varids.nil?
    v = @tipo == "number" ? 0 : false
    nombres.each do |nombre|
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
    puts "Recorriendo #{self.class}" if $debug
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @times.nil? or @instructions.nil?
    t,v = @times.recorrer
    v = v.to_f
    raise (ContextError.new(self, "Tipo de expresión no es 'number' en el número de pasos (Es #{t})")) if t!="number"
    raise (ContextError.new(self, "Número de pasos negativo")) if v<0
    i,f = 1, v.to_f
    while i<f
      @instructions.recorrer
      i+=1
    end
  end
end

class Nodo_BloqueWhile < NodoAST
  def initialize e, i
    @expression = e
    @instructions = i
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @expression.nil? or @instructions.nil?
    t,v = @expression.recorrer
    raise (ContextError.new(self, "Tipo de expresión no es 'boolean' (Es #{t})")) if t!="boolean"
    can = (v==true)
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @if.nil? or @then.nil? or @else.nil?
    t,v = @if.recorrer
    raise (ContextError.new(self, "Tipo de expresión evaluada por el IF no es 'boolean' (Es #{t})")) if t!="boolean"
    if v; @then.recorrer
    else; @else.recorrer
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @it.nil? or @ini.nil? or @fin.nil? or @paso.nil? or @instr.nil?

    $tl.push_var(@it, "number")

    ti, vi = @ini.recorrer
    raise (ContextError.new(self, "Tipo de expresión de inicio no es 'number' (Es #{ti})")) if ti!="number"
    tf, vf = @fin.recorrer
    vi, vf, paso = vi.to_s.to_f, vf.to_s.to_f, @paso.recorrer
    tp, paso = paso[0], paso[1].to_f
    raise (ContextError.new(self, "Tipo de expresión de parada no es 'number' (Es #{tf})")) if tf!="number"
    raise (ContextError.new(self, "Tipo de expresión de paso no es 'number' (Es #{tp})")) if tp!="number"
    raise (ContextError.new(self, "Expresión de parada iguala cero, ciclo infinito")) if paso==0

    i,f = vi, vf
    while i<f-0.0000000001
      $tl.var_mod(@it, i)
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
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @variables.nil? or @instructions.nil?
    @variables.recorrer
    @instructions.recorrer
  end
end

class Nodo_NewFunctionBody < NodoAST
  def initialize id, params, tipo, instr
    @id = id
    @params = params
    if tipo.nil?
      @tipo=tipo
    else
      @tipo=tipo.to_str
    end
    @instr = instr
  end

  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    $tl.open_level
      nombre = @id.recorrer.to_str
      parametros = @params.recorrer
      $tl.push_fun(nombre, @tipo, self)
      @instr.recorrer
    $tl.close_level
  end

  def execute args
    puts "Ejecutando #{@id.to_str}" if $debug
    $tl.open_level
    begin
      parametros = @params.recorrer[1] # Esto debería meter los parámetros al symtable
      
      # # Debug
      # print  "Teorico: "
      # parametros.each do |a|
      #   print a; print '  '
      # end
      # print " // Total: #{parametros.length}\n"
      # print  "Practic: "
      # args.each do |a|
      #   print a; print '  '
      # end
      # print " // Total: #{args.length}\n"
      # (0..parametros.length-1).each do |i|
      #   puts "ESTE: "+parametros[i.to_i].to_s
      #   puts "HI:"+parametros[i][0].to_s+parametros[i][1].to_s if parametros[i][0]!=parametros[i][0]
      # end
      raise (ContextError.new(self, "Número de argumentos inválido")) if parametros.length != args.length
      for i in 0..parametros.length-1
        raise (ContextError.new(self, "Tipo de argumento ##{i+1} difiere del tipo definido (#{args[i][0]} != #{parametros[i][0]})")) if parametros[i][0] != args[i][0]
        $tl.var_mod(parametros[i][1], args[i][1])
      end
        
    
      @instr.recorrer
    rescue ReturnValueE => e
      return e.eval
    ensure
      $tl.close_level
    end
    return nil
  end
end

class Nodo_BloqueProgram < NodoAST
  def initialize is
    @instructions = is
  end
  def recorrer
    puts "Recorriendo #{self.class}" if $debug
    raise (InterpreterError.new(self, "Valor nulo")) if @instructions.nil?
    @instructions.recorrer
  end
end
