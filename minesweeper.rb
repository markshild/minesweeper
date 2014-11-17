module Minesweeper

  class Tile

    NEIGHBORS = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, 1],
      [1, 1],
      [1, 0],
      [1, -1],
      [0, -1]
    ]

    def initialize(board, pos)
      @bombed = false
      @pos = pos
      @board = board
    end

    def reveal

    end

    def neighbors
      neighbors = NEIGHBORS.map do |offset|
        x, y = offset
        @board.grid[pos[0] + x][pos[1] + y]
      end

      neighbors.compact
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

    attr_reader :grid

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
