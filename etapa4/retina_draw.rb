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

# Clase para guardar la info necesaria de las llamadas a funciones de la tortuga

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
    if a == 1                             # Si la instruccion es 1) home():
      tortuga.punto = Punto.new(0, 0)     # Devuelve a la tortuga a la posicion inicial

    elsif a == 2                          # Si la instruccion es 2) openeye():
      tortuga.ojo = true                  # Activar el ojo para marcar

    elsif a == 3                          # Si la instruccion es 3) closeeye():
      tortuga.ojo = false                 # Desactivar el ojo

    elsif a == 4                          # Si la instruccion es 4) forward():
      tortuga.punto = Punto.new(0, 0)     # Esto es un poquito mas complicado, lo  dejaremos de ultimo

    elsif a == 5                          # Si la instruccion es 5) backward():
      tortuga.punto = Punto.new(0, 0)     # Esto es un poquito mas complicado, lo  dejaremos de ultimo

    elsif a == 6                          # Si la instruccion es 6) rotatel(x):
      tortuga.dir = tortuga.dir + x       # Es una formula un poco mas complicada, pero es mejor tener lo otro antes de hacer esto

    elsif a == 7                          # Si la instruccion es 7) rotater(x):
      tortuga.dir = tortuga.dir - x       # Es una formula un poco mas complicada, pero es mejor tener lo otro antes de hacer esto

    else a == 8                           # Si la instruccion es 8) setposition(x, y):
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
  row = []
  for i in 0..1000
    row += [0]
  end

  bits = []
  for i in 0..1000
    bits += row
  end

  # Time to draw! (Llenar el mapa con la información de los segmentos)
  for x in -500..500
    for y in -500..500
      segmentos.each do |seg|       # Para todos segmento s en segmentos
        punto = Punto.new(x, y)
        if estaEnSegmento punto seg
          i = 500 + x               # Calcula la fila del arreglo
          j = 500 - y               # Calcula la columa del arreglo
          bits[i][j] = 1            # Enciende el bit
        end
      end
    end
  end
end
