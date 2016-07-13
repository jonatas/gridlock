class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def  red
    colorize(31)
  end

  def green
    colorize(32)
  end

end
module GridLock

  Symbols = [
    CROSS = "✚",
    SQUARE = "▢",
    CIRCLE = "◯",
  ]

  module Pieces

    All = [

      A = [CROSS,  CIRCLE],
      B = [CROSS,  SQUARE],
      C = [SQUARE, CIRCLE],
      D = [CROSS,  CROSS ],
      E = [SQUARE, SQUARE],
      F = [CIRCLE, CIRCLE],

      G = [[SQUARE, CIRCLE], SQUARE],
      H = [[CROSS,  CIRCLE], SQUARE],
      I = [[CIRCLE, SQUARE], CROSS ],
      J = [[CROSS,  CROSS ], SQUARE],
      K = [[CIRCLE, CIRCLE], SQUARE],
      L = [[SQUARE, CIRCLE], CIRCLE],
      M = [[CROSS,  SQUARE], CIRCLE],
      N = [[SQUARE, CROSS ], CIRCLE]

    ]

    def self.multidimensional? piece
      piece[0].is_a?(Array)
    end

    def self.rotate piece
      if multidimensional? piece
        if piece[1][1] || piece[0][1]
          [[piece[1][0], piece[0][0]],
           [piece[1][1], piece[0][1]]]

        else
          [piece[1][0], piece[0][0]]
        end
      else
        [[piece[0]],[piece[1]]]
      end
    end
  end

  Board = [
    [ SQUARE,  CROSS, CIRCLE, CIRCLE ],
    [ CIRCLE, SQUARE, SQUARE,  CROSS ],
    [  CROSS,  CROSS, CIRCLE,  CROSS ],
    [  CROSS, SQUARE, CIRCLE, SQUARE ],
    [  CROSS, SQUARE,  CROSS,  CROSS ],
    [ CIRCLE, SQUARE, CIRCLE, CIRCLE ],
    [ CIRCLE, CIRCLE, SQUARE, SQUARE ]
  ]

  class Game

    def initialize
      @status = "started"
      @fill = Array.new(GridLock::Board.length) { Array.new(GridLock::Board[0].length, false) }
    end

    def spot_busy? x, y
      @fill[x][y]
    end

    def print_game
      puts "Game #@status"
      GridLock::Board.each_with_index.map do |line, line_index|
        line.each_with_index.map do |spot, column_index|
          if spot_busy?(line_index, column_index)
            print spot.red
          else
            print spot
          end
          print(" ") if column_index < line.size-1
        end
        puts
      end
    end
  end
end