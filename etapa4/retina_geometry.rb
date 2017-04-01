####################################################################################################
## INFO:
####################################################################################################

# DESCRIPCIÓN
# =====================
# Implementación de librería de métodos geometricos para los calculos de las funciones de dibujo

# AUTORES
# =====================
# Carlos Serrada      13-11347    cserradag96@gmail.com
# Mathias San Miguel  13-11310    mathiassanmiguel@gmail.com

####################################################################################################
## CLASE PARA REPRESENTAR PUNTOS EN EL PLANO:
####################################################################################################

# Clase punto
# Atributos
#   x: real, coordenada en el eje x
#   y: real, coordenada en el eje y
class Punto
  attr_accessor :x, :y

  def initialize x, y
    @x = x
    @y = y
  end
end

####################################################################################################
## FUNCIONES ARITMÉTICAS PARA LA CLASE PUNTO:
####################################################################################################

# Suma de puntos: recibe dos puntos y suma de forma vectorial
def sum p, q
  return Punto.new(p.x+q.x, p.y+q.y)
end

# Resta de puntos: recibe dos puntos y resta de forma vectorial
def diff p, q
  return Punto.new(p.x-q.x, p.y-q.y)
end

# Producto escalar entre puntos
def proPunto p, q
  return p.x*q.x+p.y*q.y
end

# Producto cruz entre puntos
def proCruz p, q
  return p.x*q.y - p.y*q.x
end

# Multiplicar un punto por un escalar
# Argumentos:
#   p: punto
#   a: real
def proEscalar p, a
  return Punto.new(p.x*a, p.y*a)
end

# Distancia al cuadrado entre dos puntos
def dist2 p, q
  return proPunto (diff p, q), (diff p, q)
end

# Distancia entre dos puntos
def dist p, q
  return Math.sqrt(dist2 p, q)
end

####################################################################################################
## FUNCIONES AVANZADAS PARA LA CLASE PUNTO:
####################################################################################################

# Proyecta el punto c en el segment ab
# Argumentos:
#   a: punto inicial del segmento
#   b: punto final del segmento
#   c: punto a proyectar
def proyectar a, b, c
  d = dist2 a, b
  if d < 0.5
    return a
  end
  r = ( proPunto (diff c, a), (diff b, a) )/(1.00*d)
  if r < 0
    return a
  end
  if r > 1
    return b
  end
  return sum a, (proEscalar (diff b, a), r)
end

# Calcula la distancia del punto c al segment ab
# Argumentos:
#   a: punto inicial del segmento
#   b: punto final del segmento
#   c: punto a proyectar
def distPuntoSegmento a, b, c
  return dist c, (proyectar a, b, c)
end

# Calcula un el desplazamieto de un punto en una direccion
# con una longitud especifica
# Argumentos:
#   p:    punto a desplazar
#   dir:  angulo en grados de la direccion
#   l:    longitud del desplazamiento
def desplazar p, dir, l
  alpha   = dir*(Math::PI)/180.00
  x       = Math.cos(alpha)*l
  y       = Math.sin(alpha)*l
  return sum p, Punto.new(x, y)
end

# Imprimir un punto
def imprimirPunto p
  print "(", p.x, ", ", p.y, ")\n"
end

####################################################################################################
## FIN :)
####################################################################################################