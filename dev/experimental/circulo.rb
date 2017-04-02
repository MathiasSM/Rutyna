bits = Array.new(1001) {|i| i = Array.new(1001, 0)}
pixel = Punto.new(0,0)
radius = 300
points = []

  points += [Punto.new(pixel.x, pixel.y + radius)]
  points += [Punto.new(pixel.x, pixel.y - radius)]
  points += [Punto.new(pixel.x + radius, pixel.y)]
  points += [Punto.new(pixel.x - radius, pixel.y)]

  f = 1 - radius
  ddF_x = 1
  ddF_y = -2 * radius
  x = 0
  y = radius
  while x < y
    if f >= 0
      y -= 1
      ddF_y += 2
      f += ddF_y
    end
    x += 1
    ddF_x += 2
    f += ddF_x
    points += [Punto.new(pixel.x + x, pixel.y + y)]
    points += [Punto.new(pixel.x + x, pixel.y - y)]
    points += [Punto.new(pixel.x - x, pixel.y + y)]
    points += [Punto.new(pixel.x - x, pixel.y - y)]
    points += [Punto.new(pixel.x + y, pixel.y + x)]
    points += [Punto.new(pixel.x + y, pixel.y - x)]
    points += [Punto.new(pixel.x - y, pixel.y + x)]
    points += [Punto.new(pixel.x - y, pixel.y - x)]
  end



  # (Encender los bits en el mapa correspondientes a los puntos calculados)
  for punto in points     # Para todo punto en segmentos
    i = 500 - punto.y        # Calcula la fila del arreglo
    j = 500 + punto.x        # Calcula la columa del arreglo
    if i.between?(0, 1000) && j.between?(0, 1000)
      bits[i][j] = 1           # Enciende el bit
    end
  end

  output = "P1\n1001 1001\n"
  for i in 0..1000
    for j in 0..1000
      output.concat(bits[i][j].to_s).concat(' ')
    end
    output.concat("\n")
  end

  # Escribir la salida en el archivo
  File.open('7.pbm', 'w') do |content|
    content.print output
  end