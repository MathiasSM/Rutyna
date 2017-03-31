############################### Funciones de dibujo ##########################

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



########################## FIN FUNCIONES DE PUNTOS ######################################
# Clase Segmento
# Atributos
#   inicio:     punto de inicio del segmento
#   direccion:  angulo del segmento con respecto al eje x
#   longitud:   longitud del segmento 
class Segmento
   attr_accessor :inicio, :direccion, :longitud

  def initialize inicio, direccion, longitud
    @inicio = inicio
    @direccion = direccion
    @longitud = longitud
  end
end


# Determina si el punto p esta en el segmento s
# Argumentos:
#   p: punto para verificar
#   s: segmento
# Retorna:
#   true:   si el punto p esta en el segmento s
#   false:  si el punto p no esta en el segmento s
def estaEnSegmento p, s
  a = s.inicio                                                            # Punto inicial del segmento
  b = desplazar a, s.direccion, s.longitud                                # Punto final del segmento
  dist = distPuntoSegmento a, b, p                                        # Distancia del punto al segmento
  if dist < (Math.sqrt 1.9)*0.5
      return true
  else
      return false
  end
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
   



################################### PRUEBAS ########################################
punto1 = Punto.new(0, 0)
punto2 = Punto.new(2, 0)

punto3 = sum punto1, punto2

def imprimirPunto p
  puts "Punto:"  
  puts p.x
  puts p.y
end

# puts punto3.x
# puts punto3.y
# puts dist2 punto1, punto2
# puts dist punto1, punto2
# imprimirPunto (proyectar punto1, punto2, Punto.new(1, 1))
# puts distPuntoSegmento punto1, punto2, Punto.new(1, 1)
# puts estaEnSegmento punto2, Segmento.new(punto1, 0, 7) 
