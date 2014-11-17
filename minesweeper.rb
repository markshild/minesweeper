module Minesweeper

  class Tile
    def initialize

    end

    def bombed?

    end

    def flagged?

    end

    def revealed?

    end

  end

  class Board

    def initialize(size = 9, mines = 10)
      @grid = Array.new(size) { Array.new(size) { Tile.new } }
      mines.times do
        loop do
          x, y = rand(size -1), rand(size - 1)
          unless @grid[x][y].bombed?
            @grid[x][y].bomb
            break
          end
        end
      end
    end

  end

  class Game
  end

end
