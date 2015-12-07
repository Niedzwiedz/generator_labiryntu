require "rubygems"
require "rubygame"

include Rubygame



# Defines a class for an example object in the game that will have a
# representation on screen ( a sprite)
class WallVert

  # Turn this object into a sprite
  include Sprites::Sprite

  def initialize(posx, posy, bl)
    # Invoking the base class constructor is important and yet easy to forget:
    super()
    @posx = posx
    @posy = posy
    # @image and @rect are expected by the Rubygame sprite code
    if bl==1
      @image = Surface.load "wall_.png"
    else
      @image = Surface.load "empty_.png"
    end
    @rect  = @image.make_rect

  end

  # Animate this object.  "seconds_passed" contains the number of ( real-world)
  # seconds that have passed since the last time this object was updated and is
  # therefore useful for working out how far the object should move ( which
  # should be independent of the frame rate)
  def update

    # This example makes the objects orbit around the center of the screen.
    # The objects make one orbit every 4 seconds

    @rect.topleft = [ @posx, @posy] 
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end
end


