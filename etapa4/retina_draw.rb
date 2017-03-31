####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# Implementación de las clases y funciones para procesar las funciones de dibujo de la tortuga de
# retina, siguiendo las especificaciones dadas para el proyecto del curso CI-3725 de la Universidad
# Simón Bolívar durante el trimestre Enero-Marzo 2017.

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com

####################################################################################################
## IMPORTACIÓN DE DEPENDENCIAS:
####################################################################################################

require_relative "retina_geometry" # Importar libreria de funciones geometricas de retina

####################################################################################################
## CLASE DE LAS INSTRUCCIONES:
####################################################################################################

class Instrucciones
  attr_accessor :id, :args
  # id: identificador de la función
  # args: argumentos de la función

  def initialize id, args=[]
    @id = id
    @args = args
  end
end

####################################################################################################
## CLASE DE LA TORTUGA:
####################################################################################################

class Turtle
  attr_accessor :angulo, :punto, :ojo
  # angulo: direccion de la cabeza de la tortuga
  # punto:  posicion de la tortuga
  # ojo:    booleano que indica si la tortuga debe marcar las lineas que recorre o no

  def initialize angulo=90, punto=Punto.new(0, 0), ojo=true
    # Por defecto la tortuga empieza en la posicion (0, 0), mirando hacia arriba (angulo = 90),
    # y ojo para marcar los pasos activado
    @angulo = angulo
    @punto = punto
    @ojo = ojo
  end

  def rotateL x
    @angulo = (@angulo+x) - (360*(((@angulo+x)/360.00).floor))
  end

  def rotateR x
    @angulo = (@angulo-x) - (360*(((@angulo-x)/360.00).floor))
  end
end

####################################################################################################
## FUNCIONES:
####################################################################################################

# Funcion que lee las instrucciones y devuelve un arreglo con los segmentos de rectas que deben ser
# dibujados
#  Argumentos:
#   - instrucciones: arreglo de instrucciones de las funciones de dibujo
#  Retorna: un arreglo de la clase Segmento, que contiene todos los segmentos dibujados

def leerInstrucciones instrucciones
  tortuga = Turtle.new()                  # Se crea la tortuga con sus valores por defecto
  segmentos  = []                         # Arreglo en el que se van agregando los segmentos conseguidos
  instrucciones.each do |a|
    if a.id == 1                          # Si la instruccion es 1) home():
      tortuga.punto = Punto.new(0, 0)     # Devuelve a la tortuga a la posicion inicial

    elsif a.id == 2                       # Si la instruccion es 2) openeye():
      tortuga.ojo = true                  # Activar el ojo para marcar

    elsif a.id == 3                       # Si la instruccion es 3) closeeye():
      tortuga.ojo = false                 # Desactivar el ojo

    elsif a.id == 4                       # Si la instruccion es 4) forward():
      ini = tortuga.punto
      dir = tortuga.angulo
      len = a.args[0]
      if tortuga.ojo
        segmentos += [Segmento.new(ini, dir, len)]
      end
      tortuga.punto = desplazar ini, dir, len

    elsif a.id == 5                       # Si la instruccion es 5) backward():
      ini = tortuga.punto
      dir = tortuga.angulo
      len = -a.args[0]
      if tortuga.ojo
        segmentos += [Segmento.new(ini, dir, len)]
      end
      tortuga.punto = desplazar ini, dir, len

    elsif a.id == 6                       # Si la instruccion es 6) rotatel(x):
      tortuga.rotateL(a.args[0])          # Rotar tortuga a la izquierda

    elsif a.id == 7                       # Si la instruccion es 7) rotater(x):
      tortuga.rotateR(a.args[0])          # Rotar tortuga a la derecha

    else                                  # Si la instruccion es 8) setposition(x, y):
      x = a.args[0]
      y = a.args[1]
      tortuga.punto = Punto.new(x, y)
    end
  end
  return segmentos
end

# Funcion que crea un arreglo de bits que representa la imagen
#  Atributos:
#   - segmentos: arreglo de Segmento, que tiene todos los segmentos que deben ser dibujados
#  Retorna:
#   - bits: arreglo de 1's y 0's que representa la imagen

def crearImagen segmentos
  # Crear mapa de bits (Arreglo de 1001 arreglos de 1001 elementos == Matriz 1001x1001)
  bits = Array.new(1001) {|i| i = Array.new(1001, 0)}


  # Time to draw! (Llenar el mapa con la información de los segmentos)
  for x in -500..500
    for y in -500..500
    segmentos.each do |seg|       # Para todos segmento s en segmentos
        punto = Punto.new(x, y)
        if estaEnSegmento punto, seg
          i = 500 - y               # Calcula la fila del arreglo
          j = 500 + x               # Calcula la columa del arreglo
          bits[i][j] = 1           # Enciende el bit
        end
      end
    end
  end



    
  File.open('7.pbm', 'w') do |line|
    line.print "P1\n1001 1001\n"
    for i in 0..1000
      for j in 0..1000
        line.print bits[i][j]
      end
      line.print "\n"
    end
  end
end

####################################################################################################
## Test:
####################################################################################################




def dosCuadrados
  instrucciones = []  
  for i in 0..3
    instrucciones += [Instrucciones.new(4, [200])]
    instrucciones += [Instrucciones.new(7, [90])]
  end

  for i in 0..3
    instrucciones += [Instrucciones.new(5, [200])]
    instrucciones += [Instrucciones.new(7, [90])]
  end
  return instrucciones
end

def dibujar_hexagono
  instrucciones = []  
  instrucciones += [Instrucciones.new(7, [90])]  
  for i in 0..5
    instrucciones += [Instrucciones.new(5, [200])]
    instrucciones += [Instrucciones.new(6, [60])]
  end
  return instrucciones
end

def dibujar_triangulo
  instrucciones = []  
  instrucciones += [Instrucciones.new(7, [90])]  
  for i in 0..5
    instrucciones += [Instrucciones.new(5, [200])]
    instrucciones += [Instrucciones.new(6, [-120])]
  end
  return instrucciones
end

def dibujar_poligono n
  instrucciones = []
  instrucciones += [Instrucciones.new(7, [90])]
  angulo = 360.00/n
  for i in 0..(n-1)
    instrucciones += [Instrucciones.new(4, [200])]
    instrucciones += [Instrucciones.new(6, [angulo])]
  end
  return instrucciones
end

poligono = dibujar_poligono 7
segments = leerInstrucciones poligono
crearImagen segments
