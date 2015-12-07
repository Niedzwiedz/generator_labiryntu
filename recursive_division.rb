require_relative 'generator'
require_relative 'wall'
require_relative 'WallH'

class RecursiveDivision < Generator
  def initialize
    @S, @E = 1, 2
    @HORIZONTAL, @VERTICAL = 1, 2
    @screen = Screen.open [ 640, 480]
    @screen.title = "Labirynth - Recursive Division"
    @sprites = Sprites::Group.new
    Sprites::UpdateGroup.extend_object @sprites
    # inicjalizacja eventow
    @event_queue = EventQueue.new
    @event_queue.enable_new_style_events
  end

  def animation(grid)
    # sciana
    grid[0].length.times do |poz|
      @sprites << WallVert.new(90+(16*poz), 75, 1)
    end
    grid.each_with_index do |row, y|
      @sprites << WallH.new(96, 88+y*16, 1)
      row.each_with_index do |cell, x|
        bottom = y+1 >= grid.length
        south  = (cell & @S != 0 || bottom)
        south2 = (x+1 < grid[y].length && grid[y][x+1] & @S != 0 || bottom)
        east   = (cell & @E != 0 || x+1 >= grid[y].length)

        if south
          @sprites << WallVert.new(90+(16*x), 93+16*y, 1)
        else
          # @sprites << WallVert.new(90+(23*x), 96+23*y, 0)
          # @sprites << WallH.new(113+23*x, 90+y*23, 0)
        end

        if east
          @sprites << WallH.new(116+16*x, 88+y*16, 1)
        else
          if south && south2
            @sprites << WallVert.new(90+(16*x), 93+16*y, 1)
          else
            # @sprites << WallVert.new(90+(23*x), 96+23*y, 0)
            # @sprites << WallH.new(113+23*x, 90+y*23, 0)
          end
        end
      end
    end
    @sprites.update

    @sprites.draw @screen

    @screen.flip
  end


  def visualise(grid)
    system "clear"
    print "\e[H" # move to upper-left
    puts " " + "_" * (grid[0].length * 2 - 1)
    grid.each_with_index do |row, y|
      print "|"
      row.each_with_index do |cell, x|
        bottom = y+1 >= grid.length
        south  = (cell & @S != 0 || bottom)
        south2 = (x+1 < grid[y].length && grid[y][x+1] & @S != 0 || bottom)
        east   = (cell & @E != 0 || x+1 >= grid[y].length)

        print(south ? "_" : " ")
        print(east ? "|" : ((south && south2) ? "_" : " "))
      end
      puts
    end
  end

  def choose_orientation(width, height)
    if width < height
      @HORIZONTAL
    elsif height < width
      @VERTICAL
    else
      rand(2) == 0 ? @HORIZONTAL : @VERTICAL
    end
  end

  def divide(grid, x, y, width, height, orientation)
    if width < 2 || height < 2
      return
    end

    visualise(grid)
    animation(grid)
    sleep(1.0/10.0)

    if orientation == @HORIZONTAL
      horizontal = orientation
    end

    # pozycja z ktorej bedzie rysowana sciana
    wall_x = x + (horizontal ? 0 : rand(width-2))
    wall_y = y + (horizontal ? rand(height-2) : 0)

    # gdzie bedzie przejscie
    passage_x = wall_x + (horizontal ? rand(width) : 0)
    passage_y = wall_y + (horizontal ? 0 : rand(height))

    # kierunek  sciany

    if horizontal
      direction_x = 1
      direction_y = 0
    else
      direction_x = 0
      direction_y = 1
    end
    # dlugosc sciay
    length = horizontal ? width : height

    # kierunek prostopadly
    dir = horizontal ? @S : @E

    length.times do
      grid[wall_y][wall_x] |= dir if wall_x != passage_x || wall_y != passage_y
      wall_x += direction_x
      wall_y += direction_y
    end

    next_x, next_y = x, y
    w, h = horizontal ? [width, wall_y-y+1] : [wall_x-x+1, height]
    divide(grid, next_x, next_y, w, h, choose_orientation(w, h))

    next_x, next_y = horizontal ? [x, wall_y+1] : [wall_x+1, y]
    w, h = horizontal ? [width, y+height-wall_y-1] : [x+width-wall_x-1, height]
    divide(grid, next_x, next_y, w, h, choose_orientation(w, h))
  end

  def generate(grid, x, y, width, height)
    @background = Surface.load "background.jpg"
    @background.blit @screen, [ 0, 0]
    divide(grid, x, y, width, height, choose_orientation(width, height))
    visualise(grid)
    should_run = true
    while should_run do
      @event_queue.each do |event|
        case event
        when Events::QuitRequested, Events::KeyReleased
          should_run = false
        end
      end
      animation(grid)
    end
  end
end
