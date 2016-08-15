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
  def purple
    colorize(35)
  end

end
module GridLock

  Symbols = [
    CROSS = "✚",
    SQUARE = "▢",
    CIRCLE = "◯",
  ]

  def self.ramdom_solution
    %w(AABCDDEFGIKN ABCDDEFFGJKM ABCCDEFFIJMN ABDDEEFFIKMN ABBCDEFFIJKM ABBCCCDFIJKM ABBCCCDDEFFJK)
      .sample
      .split("")
      .map{|piece|Object.const_get("GridLock::Pieces::#{piece}")}
  end

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
      @width = GridLock::Board[0].length
      @height = GridLock::Board.length
      @cursor_x = 0
      @cursor_y = 0
      @fill = array_board
      @cursor_hover = array_board
      @lookups = 0
    end
    def array_board
      Array.new(@height) { Array.new(@width, false) }
    end

    def spot_busy? x, y
      @fill[x][y]
    end

    def cursor_hover? x, y
      @cursor_hover[x][y] == true
    end

    def each_symbol_of piece
      piece.each_with_index do |symbol, y|
        if symbol.is_a? Array
          symbol.each_with_index do |_symbol,x|
            yield _symbol, y, x
          end
        else
          yield symbol, 0, y
        end
      end
    end

    def match? piece, x, y
      debug "match? #{piece.inspect}, #{x}, #{y}"
      each_symbol_of(piece) do |symbol, i, j|
        expected_symbol = GridLock::Board[x+i][y+j]
        debug "#{x}:#{y} - #{i}:#{j} #{expected_symbol} != <#{symbol}"
        if symbol != expected_symbol
          return false
        end
      end
      return true
    end

    def fill x, y
      fail "spot busy: #{x}, #{y}" if spot_busy? x,y
      @fill[x][y] = true
    end

    def finished?
      @fill.all?{|row|row.all?&:true?}
    end

    def print_for(piece)
      return unless piece
      if piece.any?{|e|e.is_a?(Array)}
        if piece[0][0] == nil
          [piece[0].join("\n"),piece[1]]
        elsif piece[0][1] == nil
          [piece[0].join(" "),piece[1].join(" ")]
        else
          [piece[1], piece[0]]
        end.join("\n")
      else
        piece.join(" ") + "\n"
      end.to_s + " \n\n" + piece.inspect + "\n\n"
    end
    def hover(x,y)
      @cursor_hover[@cursor_x][@cursor_y] = false
      @cursor_x = x
      @cursor_y = y
      @cursor_hover[@cursor_x][@cursor_y] = true
      yield
    end

    def finished?
      @fill.map{|row|row.count {|col|col == true}}.inject(:+) == @fill.length * @fill[0].length
    end

    def width
      @fill[0].size
    end

    def height
      @fill.size
    end

    def fit? piece, x=0, y=0
      puts "no piece" and return false unless piece
      hover(x,y) do
        puts "\e[H\e[2J \n Loop: #{@lookups+=1}, (#{x},#{y})\n",
          print_for(piece)
          print_game
          sleep 0.01
          each_symbol_of piece do |_, i,j|
            return false if x+i > width
            return false if @fill[x+i][y+j]
          end
          return false unless match?(piece, x, y)
          return true
      end
    end

    def put! piece, x, y
      raise "piece: #{piece.inspect} does not fit on #{x}, #{y}" unless fit? piece, x, y
      each_symbol_of piece do |_, i,j|
        fill(x+i, y+j)
      end
      true
    end

    def print_game
      print "\n"
      GridLock::Board.each_with_index.map do |line, line_index|
        line.each_with_index.map do |spot, column_index|
          if spot_busy?(line_index, column_index)
            print spot.red
          elsif cursor_hover?(line_index, column_index)
            print spot.purple
          else 
            print spot.green
          end
          print(" ") if column_index < line.size-1
        end
        puts
      end
    end

    def debug message
      puts message if @debug
    end

    def debug!
      @debug = true
    end
  end
end