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

class RubynaFunction
  def initialize name, rubycode
    @name = name
    @rubycode = rubycode
  end
  def execute args
    @rubycode.call( @name, args)
  end
end
  
  
# TABLA
# =====================
class SymbolTable
  attr_accessor :table
  
  def initialize
    @table = []
  end
end

# LISTA DE TABLAS (mayor índice == scope más interno)
# =====================
class TableList
  attr_accessor :meta, :funtable
  
  def initialize
    @varlist = [[SymbolTable.new()]]            # Lista de tablas de VarSymbols
    @funtable = SymbolTable.new()               # Una única tabla de FunSymbols
    @capas_pintura = []
    self.addRetinaMagic
  end
  
  def addRetinaMagic
    funcionesRetina = ["home","openeye","closeeye","forward","backward","rotatel","rotater","setposition"]
    funcionesRetina.each_with_index do |name,i|
      puts $paint.class
      self.push_fun( name, nil, RubynaFunction.new(i+1, $paint.method(:addCapa)))
    end
  end
  
  def open_level;   @varlist.push [SymbolTable.new()]; end
  def close_level;  @varlist.pop; end
  
  def open_scope;   @varlist[-1].push SymbolTable.new(); end
  def close_scope;  @varlist[-1].pop; end
  
  def push_var symbol_name, type=nil, value=nil
    @varlist[-1][-1].table.push VarSymbol.new(symbol_name, type, value)
  end
  
  def push_fun symbol_name, type=nil, value=nil
    @funtable.table.push FunSymbol.new(symbol_name, type, value)
  end
  
  def var_exists? symbol_name
    scope_dist = 0
    puts "\n\nSearching for "+symbol_name
    @varlist[-1].reverse.each do |scope|
      i=scope_dist
      while i>0; print "  "; i=-1; end
      puts "====SCOPE #"+scope_dist.to_s+" ================="
      scope.table.each do |symbol|
        i=scope_dist
        while i>0; print "  "; i=-1; end
        puts "checking: #{symbol_name} == #{symbol.name} ? "
        if symbol.name == symbol_name
          puts "====> DIS "+symbol_name+ " EXISTS. Type:#{symbol.type} Val:#{symbol.value}"
          return (symbol.type), (symbol.value)
        end
      end
      scope_dist += 1
    end
    puts "====> NEIN"
    return false # Doesn't exist? Return these
  end
  
  def fun_exists? symbol_name
    puts symbol_name + " exists?"
    @funtable.table.each do |function|
      if function.name == symbol_name
        puts function.name + "! YES"
        return true, function.type
      end
    end
    puts "NEIN"
    return false, ""
  end
  
  def exec_fun symbol_name, args
    @funtable.table.each do |function|
      if function.name == symbol_name
        $tl.open_level
          return function.value.execute args
        $tl.close_level
      end
    end
    raise (ContextError.new(self, "Función #{@name} no ha sido declarada"))
  end
end
