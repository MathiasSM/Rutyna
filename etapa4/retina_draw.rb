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

# Intenta adaptar tu código a usar esta clase en vez de Instrucciones. Me facilita el usar lo de var = method :C
# Clase CapasPintura que tiene .cola una lista de instrucciones por pintar
class CapasPintura
  attr_accessor :cola
  # Subclase Capa que tiene name y args, para tu uso en for cola do |elemCola| blah
  # No te pasaré los id, sácalos tú xD
  class Capa
    attr_accessor :id, :args
    def initialize id, args=[]
      @id = id
      @args = args
    end
  end

  def initialize
    @cola = []
  end
  def addCapa id, args
    @cola.push Capa.new(id, args)
    return nil
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
    @angulo = (@angulo+x) - (360*(((@angulo+x)/360.00).round))
  end

  def rotateR x
    @angulo = (@angulo-x) - (360*(((@angulo-x)/360.00).round))
  end
end

####################################################################################################
## FUNCIONES:
####################################################################################################

# Funcion representativa del algoritmo de Bresenham's Line
#  Argumentos:
#   - a: punto inicial
#   - b: punto final
#  Retorna: un arreglo de puntos pertenecientes a la recta recta entre los puntos a y b

def get_line a, b
  points = []
  steep = ((b.y-a.y).abs) > ((b.x-a.x).abs)

  if steep
    a.x,a.y = a.y,a.x
    b.x,b.y = b.y,b.x
  end

  if a.x > b.x
    a.x,b.x = b.x,a.x
    a.y,b.y = b.y,a.y
  end

  deltax = b.x-a.x
  deltay = (b.y-a.y).abs
  error = (deltax / 2).to_i
  y = a.y
  ystep = nil

  if a.y < b.y
    ystep = 1
  else
    ystep = -1
  end

  for x in a.x.round..b.x.round
    if steep
      points += [Punto.new(y, x)]
    else
      points += [Punto.new(x, y)]
    end
    error -= deltay
    if error < 0
      y += ystep
      error += deltax
    end
  end

  return points
end


# Funcion que lee las instrucciones y devuelve un arreglo con los segmentos de rectas que deben ser
# dibujados
#  Argumentos:
#   - instrucciones: arreglo de instrucciones de las funciones de dibujo
#  Retorna: un arreglo de la clase Segmento, que contiene todos los segmentos dibujados

def procesarCapa
  tortuga = Turtle.new()                  # Se crea la tortuga con sus valores por defecto
  segmentos  = []                         # Arreglo en el que se van agregando los segmentos conseguidos
  for a in $paint.cola
    if a.id == 1                          # Si la instruccion es 1) home():
      tortuga.punto = Punto.new(0, 0)     # Devuelve a la tortuga a la posicion inicial

    elsif a.id == 2                       # Si la instruccion es 2) openeye():
      tortuga.ojo = true                  # Activar el ojo para marcar

    elsif a.id == 3                       # Si la instruccion es 3) closeeye():
      tortuga.ojo = false                 # Desactivar el ojo

    elsif a.id == 4                       # Si la instruccion es 4) forward():
      ini = tortuga.punto
      dir = tortuga.angulo
      len = a.args[0][1]

      tortuga.punto = desplazar ini, dir, len

      if tortuga.ojo
        fin = desplazar ini, dir, len
        puntos = get_line ini, fin
        segmentos += puntos
      end

    elsif a.id == 5                       # Si la instruccion es 5) backward():
      ini = tortuga.punto
      dir = tortuga.angulo
      len = -a.args[0][1]

      tortuga.punto = desplazar ini, dir, len

      if tortuga.ojo
        fin = desplazar ini, dir, len
        puntos = get_line ini, fin
        segmentos += puntos
      end

    elsif a.id == 6                          # Si la instruccion es 6) rotatel(x):
      tortuga.rotateL(a.args[0][1])          # Rotar tortuga a la izquierda

    elsif a.id == 7                          # Si la instruccion es 7) rotater(x):
      tortuga.rotateR(a.args[0][1])          # Rotar tortuga a la derecha

    else                                     # Si la instruccion es 8) setposition(x, y):
      x = a.args[0][1]
      y = a.args[1][1]
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

  # Time to draw!
  # (Encender los bits en el mapa correspondientes a los puntos calculados)
  for punto in segmentos     # Para todo punto en segmentos
    i = 500 - punto.y        # Calcula la fila del arreglo
    j = 500 + punto.x        # Calcula la columa del arreglo
    if i.between?(0, 1000) && j.between?(0, 1000)
      bits[i][j] = 1           # Enciende el bit
    end
  end

  # Generar salida
  output = "P1\n1001 1001\n"
  for i in 0..1000
    for j in 0..1000
      output.concat(bits[i][j].to_s)
    end
    output.concat("\n")
  end

  # Escribir la salida en el archivo
  File.open('7.pbm', 'w') do |content|
    content.print output
  end
end

####################################################################################################
## Test:
####################################################################################################

def dosCuadrados
  for i in 0..3
    $paint.addCapa(4, [200])
    $paint.addCapa(7, [90])
  end

  for i in 0..3
    $paint.addCapa(5, [200])
    $paint.addCapa(7, [90])
  end
end

def dibujar_hexagono
  $paint.addCapa(7, [90])
  for i in 0..5
    $paint.addCapa(5, [200])
    $paint.addCapa(6, [60])
  end
end

def dibujar_triangulo
  $paint.addCapa(7, [90])
  for i in 0..5
    $paint.addCapa(5, [200])
    $paint.addCapa(6, [-120])
  end
end

def dibujar_poligono n
  $paint.addCapa(7, [90])
  angulo = 360.00/n
  for i in 0..(n-1)
    $paint.addCapa(4, [200])
    $paint.addCapa(6, [angulo])
  end
end
