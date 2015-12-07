require_relative 'generator'

require_relative 'wall'
require_relative 'WallH'

class RecursiveBacktracking < Generator
  attr_reader :width, :height
  def initialize
    @NORTH, @SOUTH, @EAST, @WEST = 1, 2, 4, 8
    @DEST_X = { @EAST => 1, @WEST => -1, @NORTH => 0, @SOUTH => 0 }
    @DEST_Y = { @EAST => 0, @WEST =>  0, @NORTH => -1, @SOUTH => 1 }
    @OPPOSITE = { @EAST => @WEST, @WEST => @EAST, @NORTH => @SOUTH, @SOUTH => @NORTH }
    @screen = Screen.open [ 640, 480]
    @screen.title = "Labirynth - Recursive Backtracking"
    @sprites = Sprites::Group.new
    Sprites::UpdateGroup.extend_object @sprites
    @event_queue = EventQueue.new
    @event_queue.enable_new_style_events
  end
  def animation(grid, width, height)
    # Rysowanie sciany top
    width.times do |poz|
      @sprites << WallVert.new(90+(17*poz), 73, 1)
    end
    height.times do |y|
      # rysowanie sciany left
      @sprites << WallH.new(93, 87+y*18, 1)
      width.times do |x|
        if(!(grid[y][x] & @SOUTH != 0))
          @sprites << WallVert.new(90+17*x, 94+y*18, 1)
          @sprites << WallH.new(113+x*17,87+y*18, 0)
         else
           @sprites << WallVert.new(90+17*x, 94+y*18, 0)
           @sprites << WallH.new(113+x*17,87+y*18, 0)
        end
        if (grid[y][x] & @EAST != 0)
          if(!((grid[y][x] | grid[y][x+1]) & @SOUTH != 0))
            @sprites << WallVert.new(90+17*x, 94+y*18, 1)
            @sprites << WallH.new(113+x*17,87+y*18, 0)
          # else
           #@sprites << WallVert.new(90+23*x, 96+y*23, 0)
          end
        else
          @sprites << WallH.new(113+x*17,87+y*18, 1)
        end
      end
    end

    @sprites.update

    @sprites.draw @screen

    @screen.flip
    @sprites.clear
  end
  def visualise(grid, width, height)
    system "clear"
    @sprites.undraw @screen, @background
    # Clear sprites somehow
    #TODO
    puts "_" * (2 * width )
    # width.times do |poz| 
    #   @sprites << WallVert.new(90+(30*poz), 73, 1)
    # end
    # rysowanie sciany gora
    # TODO => dodaj obiekt klasy Sciany poziom
    height.times do |y|
      print "|"
      # @sprites << WallH.new(90, 90+y*19, 1)
      # TODO => dodaj obiekt klasy Sciany pion
      width.times do |x|
        print((grid[y][x] & @SOUTH != 0) ? " " : "_")
        # if(!(grid[y][x] & @SOUTH != 0))
        #   @sprites << WallVert.new(90+30*x, 90+y*19, 1)
        # else
        #   @sprites << WallVert.new(90+30*x, 90+y*19, 0)
        # end
        # TODO => jezeli warunek true to kolor obiektu
        # zmieniamy na kolor tla
        # W przeciwnym wypadku stworz obiekt z kolorem
        # scian
        if (grid[y][x] & @EAST != 0)
          print(((grid[y][x] | grid[y][x+1]) & @SOUTH != 0) ? " " : "_")
          # if(!((grid[y][x] | grid[y][x+1]) & @SOUTH != 0))
          #  @sprites << WallVert.new(90+30*x, 90+y*19, 1)
          # else
          #  @sprites << WallVert.new(90+30*x, 90+y*19, 0)
          # end
        else
          print "|"
          # @sprites << WallH.new(120+x*30,90+y*19, 1)
          # DOPISAC DODATKOWY WARUNEK
          # USUWAJACY |
        end
      end
      puts
    end
  end

  def carve_passage(current_x,current_y,grid, width, height)

    directions = [@NORTH, @SOUTH, @EAST, @WEST].sort_by{rand}

    sleep(1.0/8.0)
    #system "clear"
    #height.times do |y|
    #  width.times do |x|
    #    print grid[y][x]
    #  end
    #puts
    #end
    visualise(grid, width, height)
    animation(grid, width, height)
    directions.each do |direction|
      next_x, next_y = current_x + @DEST_X[direction], current_y + @DEST_Y[direction]

      if next_y.between?(0, grid.length-1) && next_x.between?(0, grid[next_y].length-1) && grid[next_y][next_x] == 0
        grid[current_y][current_x] |= direction
        grid[next_y][next_x] |= @OPPOSITE[direction]
        carve_passage(next_x, next_y, grid, width, height)
      end
    end
  end


  def generate(grid, x, y, width, height)
    @background = Surface.load "background.jpg"
    @background.blit @screen, [ 0, 0]
    carve_passage(0, 0, grid, width, height)
    visualise(grid, width, height)
    should_run = true
    while should_run do
      @event_queue.each do |event|
        case event
        when Events::QuitRequested, Events::KeyReleased
          should_run = false
        end
      end
      animation(grid, width, height)
    end
  end
end
