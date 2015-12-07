require_relative 'recursive_backtracking'
require_relative 'recursive_division'

class Labirynth
  attr_reader :width, :height, :grid
  def initialize(width = 10, height = 10, generator)
    @width = width
    @height = height
    @grid = Array.new(@height) {Array.new(@width, 0)}
    @seed = rand(0xFFFF_FFFF).to_i
    srand(@seed)
    @generator = generator
  end
  def generate
    @generator.generate(@grid, 0,0, @width, @height)
  end
end
labirynth = Labirynth.new(10,10,RecursiveDivision.new)
labirynth.generate
