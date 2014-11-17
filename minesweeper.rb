module Minesweeper

  class Tile
    def initialize(board, pos)
      @bombed = false
      @pos = pos
      @board = board
    end

    def reveal

    end

    def neighbors

    end

    def neighbor_bomb_count

    end

    def bombed?
      @bombed
    end

    def flagged?

    end

    def revealed?

    end

    def set_bomb
      @bombed = true
    end

    def inspect
    end
  end

  class Board

    def initialize(size = 9, mines = 10)
      @grid = Array.new(size) {|x| Array.new(size) {|y| Tile.new(self,[x,y]) } }
      mines.times do
        loop do
          x, y = rand(size -1), rand(size - 1)
          unless @grid[x][y].bombed?
            @grid[x][y].set_bomb
            break
          end
        end
      end
    end

  end

  class Game
  end

end
