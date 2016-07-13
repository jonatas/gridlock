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
    end

    def print
      puts "Game #@status"
      GridLock::Board.each do |line|
        puts line.join(" ")
      end
    end
  end
end