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

      G = [[SQUARE,CIRCLE], SQUARE],
      H = [[CROSS, CIRCLE], SQUARE],
      I = [[CIRCLE,SQUARE], CROSS ],
      J = [[CROSS ,CROSS ], SQUARE],
      K = [[CIRCLE,CIRCLE], SQUARE],
      L = [[CIRCLE,SQUARE], CIRCLE],
      M = [[CROSS, SQUARE], CIRCLE],
      N = [[SQUARE, CROSS], CIRCLE]

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
        [[piece[0],nil],[piece[1],nil]]
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

  class GameError < StandardError
  end

  class Game
    attr_reader :history, :cols, :lines, :cursor_hover
    def initialize
      @status = "started"
      @cols = GridLock::Board[0].length
      @rows = GridLock::Board.length
      @fill = array_board
      @cursor_hover = array_board
      @lookups = 0
      @history = []
    end

    def array_board
      Array.new(@rows) { Array.new(@cols, false) }
    end

    def spot_busy? col, row
      @fill[row][col]
    end

    def cursor_hover? col, row
      @hover == [col, row]
    end
    def simple? piece
      piece.length == 2 &&
        piece.none?{|e|e.is_a?Array}
    end

    def each_symbol_of piece, &block
      piece.each_with_index do |symbol, i|
        if symbol.is_a? Array
          symbol.each_with_index do |_symbol,y|
            block.call _symbol, i, y if _symbol
          end
        elsif symbol
          if simple? piece
            block.call symbol, 0, i
          else
            block.call symbol, i, 0
          end
        end
      end
    end

    def navigate
      yields = []
      (0...@rows).each do |row|
        (0...@cols).each do |col|
          yields << yield(col, row)
        end
      end
      yields.compact
    end

    def around col, row 
      debug "around(#{col},#{row}) ? if col+1 < @cols:: #{col+1} < #{@cols}) || if row+1 < @rows :: #{row+1} < #{@rows}"
      [
        ([col-1, row] if col > 0),
        ([col, row-1] if row > 0),
        ([col+1, row] if col+1 < @cols),
        ([col, row+1] if row+1 < @rows),
      ].compact
    end

    def enclosures
      navigate do |col, row|
        next if spot_busy? col, row
        [col,row] if enclosured? col, row
      end
    end

    def enclosured? col, row
      debug "enclosured?: #{col}:#{row}: #{around(col, row).inspect}"
      found = around(col, row).all?{|(_col,_row)| debug("spot_busy?(#{_col},#{_row}) # => #{busy=spot_busy?(_col,_row)}"); busy}
      debug "? #{col}:#{row}: #{found}"
      found
    end

    def match? piece, row, col
      debug "match? #{piece.inspect}, row: #{row}, col: #{col}"
      each_symbol_of(piece) do |symbol, _row, _col|
        debug "> match? #{symbol}, _row: #{_row}, _col: #{_col}"
        if row + _row > @rows-1 || col + _col > @cols-1
          debug "Out of board: #{row} + #{_row} > #{@rows-1} || #{col} + #{_col} > #{@cols-1}"
          return false
        end
        expected_symbol = GridLock::Board[row+_row][col+_col]
        if symbol != expected_symbol
          debug "#{row}:#{col} - #{_row}:#{_col} #{symbol} != #{expected_symbol}"
          return false
        end
        debug "#{row}:#{col} - #{_row}:#{_col} #{symbol} == #{expected_symbol}"
      end
      return true
    end

    def fill col, row
      raise GameError, "spot busy: #{col}, #{row}" if spot_busy? col, row
      @fill[row][col] = true
    end

    def take_out col, row
      raise GameError, "nothing to take out on #{col}, #{row}" unless spot_busy? col, row
      @fill[row][col] = false
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
      end.to_s + " \n\n"
    end

    def hover(col, row)
      @hover = [col, row]
      yield
      @hover = []
    end


    def fit? piece, col=0, row=0
      return false unless piece
      fit = true
      hover(col,row) do
        puts "\e[H\e[2J \n Loop: #{@lookups+=1}, (#{col},#{row})\n", print_for(piece)
        print_game
        sleep 0.01
        each_symbol_of piece do |_sym, _col, _row|
          if col+_col > @cols || row+_row > @rows || spot_busy?(col, row)
            fit = false 
            break 
          end
        end
        unless match?(piece, row, col)
          fit = false 
        end
      end
      fit
    end

    def put! piece, col, row
      raise GameError, "piece: #{piece.inspect} does not fit on row: #{row}, col: #{col}" unless fit? piece, col, row
      @history << []
      each_symbol_of piece do |_, i,j|
        _col, _row = col+i, row+j
        fill(_col, _row)
        @history.last << [_col, _row]
      end
      enclosured_points = enclosures
      unless enclosured_points.empty?
        raise GameError, "#{piece.inspect} on (#{x},#{y}) enclosures: #{enclosures.inspect}"
      end
      true
    end

    def undo
      raise GameError, "History empty! Nothing to undo." if @history.empty?
      action = @history.pop
      action.each do |(col, row)|
        take_out col, row
      end
    end

    def print_game color=true
      print "\n"
      GridLock::Board.each_with_index.map do |line, line_index|
        line.each_with_index.map do |spot, column_index|
          if color
            if spot_busy?(line_index, column_index)
              print spot.red
            elsif cursor_hover?(line_index, column_index)
              print spot.purple
            else 
              print spot.green
            end
          else
            print spot
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