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
      @flagged = false
      @revealed = false
    end


    def neighbors
      neighbors = NEIGHBORS.map do |offset|
        x, y = offset
        if (@pos[0] + x).between?(0, @board.grid.size-1) &&
           (@pos[1] + y).between?(0, @board.grid.size-1)

          @board.grid[@pos[0] + x][@pos[1] + y]
        else
          nil
        end
      end

      neighbors.compact
    end

    def neighbor_bomb_count
      neighbors.count {|neighbor| neighbor.bombed?}
    end

    def bombed?
      @bombed
    end

    def set_flag
      @flagged = !@flagged
    end

    def flagged?
      @flagged
    end

    def revealed?
      @revealed
    end

    def reveal
      @revealed = true
      return false if bombed?
      if neighbor_bomb_count.zero?
        neighbors.each do |neighbor|
          neighbor.reveal unless neighbor.bombed? || neighbor.revealed?
        end
      end
    end

    def set_bomb
      @bombed = true
    end

    def display_status
      return 'F' if flagged?
      return '*' unless revealed?
      return 'X' if bombed?
      nbc =  neighbor_bomb_count
      nbc.zero? ? '_' : nbc
    end

    def inspect
      "@pos = #{@pos}, @bombed = #{@bombed}"

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
      #reveal_all
      display
    end

    def display
      display = @grid.map do |x|
        x.map do |y|
          y.display_status
        end.join(' ')
      end
      puts display
      # (0...size).each do |x|
      #   (0...size).each do |y|
      #     @grid[x][y]
      #   end
      #
      # end
    end

    def reveal_all
      @grid.each { |row| row.each { |t| t.reveal } }
    end

  end

  class Game
  end

end
