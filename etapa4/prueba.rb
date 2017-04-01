def draw_circle(pixel, radius)
    self[pixel.x, pixel.y + radius] = 1
    self[pixel.x, pixel.y - radius] = 1
    self[pixel.x + radius, pixel.y] = 1
    self[pixel.x - radius, pixel.y] = 1

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
      self[pixel.x + x, pixel.y + y] = 1
      self[pixel.x + x, pixel.y - y] = 1
      self[pixel.x - x, pixel.y + y] = 1
      self[pixel.x - x, pixel.y - y] = 1
      self[pixel.x + y, pixel.y + x] = 1
      self[pixel.x + y, pixel.y - x] = 1
      self[pixel.x - y, pixel.y + x] = 1
      self[pixel.x - y, pixel.y - x] = 1
    end
  end
end

draw_circle(Punto.new(14,14), 12)