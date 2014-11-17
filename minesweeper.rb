require 'colorize'
require 'yaml'

module Minesweeper

  class Tile

    COLOR_NUMBERS = {
      1 => :blue,
      2 => :green,
      3 => :light_red,
      4 => :magenta,
      5 => :yellow,
      6 => :light_blue,
      7 => :cyan,
      8 => :light_black
    }

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
      @flagged = !@flagged unless revealed?
    end

    def flagged?
      @flagged
    end

    def revealed?
      @revealed
    end

    def reveal
      @revealed = true
      if neighbor_bomb_count.zero?
        neighbors.each do |neighbor|
          neighbor.reveal unless neighbor.bombed? ||
          neighbor.revealed? || neighbor.flagged?
        end
      end
      true
    end

    def set_bomb
      @bombed = true
    end

    def display_status
      return 'F'.colorize(:magenta) if flagged?
      return '*'.colorize(:default) unless revealed?
      return 'X'.colorize(:red) if bombed?
      nbc = neighbor_bomb_count
      nbc.zero? ? '_'.colorize(:light_black) : nbc.to_s.colorize(COLOR_NUMBERS[nbc])
    end

    def clear
      if revealed? && neighbors.count(&:flagged?) == neighbor_bomb_count
        neighbors.reject(&:flagged?).each {|n| n.reveal }
      end
    end

    def inspect
      "@pos = #{@pos}, @bombed = #{@bombed}"

    end
  end

  class Board

    attr_reader :grid

    def initialize(size, mines)
      @grid = Array.new(size) {|x| Array.new(size) {|y| Tile.new(self,[x,y]) } }
      @mines = mines

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

    def display
      display = @grid.map.with_index do |x, i|
        x.map do |y|
          y.display_status
        end.unshift(i).join(' ')
      end
      display.unshift("  0 1 2 3 4 5 6 7 8")

      puts display
      # (0...size).each do |x|
      #   (0...size).each do |y|
      #     @grid[x][y]
      #   end
      #
      # end
    end

    def lost?
      @grid.any? do |x|
        x.any? {|y| y.revealed? && y.bombed?  }
      end
    end

    def won?
      revealed_count = @grid.map do |x|
        x.count {|y| y.revealed? }
      end.inject(:+)
      revealed_count == @grid.size**2 - @mines
    end

    def reveal_all
      @grid.each { |row| row.each { |t| t.reveal } }
      display
    end



  end

  class Game

    def initialize(should_load = false, size = 9, mines = 10)
      @game_board = Board.new(size, mines)
      @save_time = 0
    end

    def get_input

      while true
        puts "Please enter a coordinate and action (F for flag, R for Reveal, C for Clear)"
        input = gets.chomp
        return input if input == "save"
        input = input.split(' ')
        break if good_input?(input)
        puts "Invalid input. Please try again."
      end
      input
    end

    def process_input(input)
      action, x, y = input
      x, y = x.to_i, y.to_i
      tile = @game_board.grid[x][y]
      if action.upcase == 'F'
        tile.set_flag
      elsif action.upcase == 'R'
        tile.reveal
      elsif action.upcase == 'C'
        tile.clear
      else
        raise "we should never see this."
      end
    end

    def play
      puts "Welcome to Minesweeper!"
      @start_time = Time.new
      while true
        system("clear")
        @game_board.display
        input = get_input
        if input == "save"
          save
          puts "Game saved!"
        else
          process_input(input)
        end

        if @game_board.lost?
          @game_board.reveal_all
          puts "Game Over"
          break
        end

        if @game_board.won?
          end_time = Time.new
          @game_board.reveal_all
          puts "CONGRATULATIONS!!!!!!!!!!!"
          time = end_time - @start_time + @save_time
          puts "You finished in #{time} seconds"
          break
        end

      end

    end

    def save
      @save_time = Time.new - @start_time
      yaml = self.to_yaml
      File.open("savefile.yaml", "w") do |file|
        file.write(yaml)
      end

    end

    private

    def good_input?(input)
      return true if input == "save"
      input.size == 3 && (input[0] =~ /[FRC]/i) && input.drop(1).all? do |i|
        (0...@game_board.grid.size) === i.to_i
      end
    end









  end

end

if __FILE__ == $PROGRAM_NAME

  if ARGV.shift == "load"
    game = YAML.load(File.read("savefile.yaml")).play
    game.start_time = Time.now
  else
    Minesweeper::Game.new.play
  end
end
