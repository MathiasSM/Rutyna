####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# CLASE(S) para la TABLA DE SIMBOLOS del lenguaje Retina.
# Basado en los ejemplos aportados por el preparador David Lilue y siguiendo las
# especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com



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
        return true, function.type
      end
    end
    return false, ""
  end
  
  def exec_fun symbol_name
    @funtable.each do |function|
      if function.name == symbol_name
        # Execute here
        return "type", 1
      end
    end
    return "Error", -1  # If not found
  end
end
