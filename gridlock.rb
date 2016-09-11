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
class Array
  def sample!
    delete_at rand length
  end
end
module GridLock

  Symbols = [
    CROSS = "✚",
    SQUARE = "▢",
    CIRCLE = "◯",
  ]

  def self.solutions
    [
      'AABBCCDFGIJK', 'AABBCCDFGJLN', 'AABBCCCDEFFIJ', 'AABBCCCDEFFJN', 'AABBCCCDJKLM',
      'AABBCCCDDEFHK', 'AABBFGIJKMN', 'AABBBCFFGJMN', 'AABBBCCCDDFGL', 'AAABCCDEEFFIJ',
      'AAABCCDEEFFHJ', 'AAABCDDEEFFGN', 'AAABCCDDEEFKM', 'AAABBCEFJKMN', 'AAABBEFFGJMN',
      'AAABBBCCCDFGH', 'AAABBBCCEFFIJ', 'AAABCDEFGIMN', 'AAABCCDDEEFHL', 'AAABCCCDGIJL',
      'AAABBCEFIJKM', 'AAABBCCCDDEEFF', 'AAABBCCDGHKM', 'AAAABBCCDEFGI', 'AAACCCDEIJLN',
      'AAABBCCCIJLN', 'AAAABCCDEEFHM', 'AAAABCCDEEFIM', 'AAAABBBCCCFGJ', 'AAAABBBCCDEEFF'
    ].inject({}){|h,e| h[e] = e.split('').map{|piece|Object.const_get("GridLock::Piece::#{piece}")}; h}
  end

  def self.ramdom_solution
    key = solutions.keys.sample
    [key, solutions[key]]
  end

  def self.get_pieces_for solution
    solution
  end

  module Piece

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
      piece.any? {|e|e.is_a?(Array) && e.compact.length > 1}
    end

    def self.rotations piece
      unless multidimensional? piece
        [
          piece,
          [[piece[0]], [piece[1]]],
          piece.reverse,
          [[piece[1]],[piece[0]]]
        ]
      else
        [ piece,
          r1 = rotate(piece),
          r2 = rotate(r1),
          rotate(r2)
        ]
      end
    end

    def self.rotate piece
      if piece[1][1] || piece[0][1]
        [[piece[1][0], piece[0][0]],
         [piece[1][1], piece[0][1]]]
      else
        [piece[1][0], piece[0][0]]
      end
    end

    def self.print(piece)
      return unless piece
      stdout =
        if Piece.multidimensional? piece
          piece.map do |row|
            row = [row] unless row.is_a? Array
            row.map {|e|e || " "}.join(" ")
          end
        else
          if piece[0].is_a? String
            [piece.join(" "),'']
          else
            piece
          end
        end
      puts stdout
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
    attr_reader :history, :cols, :lines, :cursor_hover, :started_at, :pieces, :lookups
    def initialize pieces: [], board: GridLock::Board
      @cols = board[0].length
      @rows = board.length
      @fill = array_board
      @started_at = Time.now
      @cursor_hover = array_board
      @lookups = 0
      @history = []
      @pieces = pieces
    end

    def array_board
      Array.new(@rows) { Array.new(@cols, false) }
    end

    def get_piece!
       @pieces.sample
    end

    def spot_busy? row, col
      @fill[row][col]
    end

    def cursor_hover? row, col
      @hover == [row, col]
    end

    def free_positions
      positions = []
      navigate do |row, col|
        next if spot_busy? row, col
        positions << [row,col]
      end
      positions
    end


    def each_symbol_of piece, &block
      piece.each_with_index do |symbol, i|
        if symbol.is_a? Array
          symbol.each_with_index do |_symbol,y|
            block.call(_symbol, i, y) if _symbol
          end
        elsif symbol
          params = GridLock::Piece.multidimensional?(piece) ? [i,0] : [0,i]
          block.call(symbol, *params)
        end
      end
    end

    def navigate
      yields = []
      (0...@rows).each do |row|
        (0...@cols).each do |col|
          yields << yield(row, col)
        end
      end
      yields.compact
    end

    def around row, col
      debug "around(#{row},#{col}) ? if col+1 < @cols:: #{col+1} < #{@cols}) || if row+1 < @rows :: #{row+1} < #{@rows}"
      [
        ([row, col-1] if col > 0),
        ([row-1, col] if row > 0),
        ([row, col+1] if col+1 < @cols),
        ([row+1, col] if row+1 < @rows),
      ].compact
    end

    def enclosures
      navigate do |row, col|
        next if spot_busy? row, col
        [row, col] if enclosured? row, col
      end
    end

    def enclosured? row, col
      debug "enclosured?: row: #{row}, col: #{col} #{around(row, col).inspect}"
      found = around(row, col).all?{|(_row,_col)| debug("spot_busy?(#{_row},#{_col}) # => #{busy=spot_busy?(_row,_col)}"); busy}
      debug "? row: #{row}, col: #{col}, found enclosured?: #{found}"
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


    def finished?
      @fill.all?{|row|row.all?&:true?}
    end


    def hover(row, col)
      @hover = [row, col]
      yield
      @hover = []
    end


    def fit? piece, row=0, col=0
      @lookups+=1
      fit = true
      hover(row, col) do
        navigate_on piece, row, col do |_row, _col|
          if _col > @cols-1 || _row > @rows-1 || spot_busy?(_row, _col)
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

    def status col: nil, row: nil, piece: nil
      puts "\e[H\e[2J",
        "loop: #{@lookups}, row: #{row}, col: #{col}), pieces: #{@pieces.length}\n"
      GridLock::Piece.print(piece)
      print_game
    end

    def navigate_on piece, row, col
      each_symbol_of piece do |_, r,c|
        yield(row+r, col+c)
      end
    end

    def remove_from_pieces! piece
      if (index = @pieces.index{|_piece|GridLock::Piece.rotations(_piece).include?(piece) })
        @pieces.delete_at(index)
      end
    end

    def put! piece, row, col
      raise GameError, "piece: #{piece.inspect} does not fit on row: #{row}, col: #{col}" unless fit? piece, row, col
      status(row: row, col: col, piece: piece)
      remove_from_pieces! piece
      @history << [piece, []]
      navigate_on piece, row, col do |_row, _col|
        fill(_row, _col)
        @history.last.last << [_row, _col]
      end
      enclosured_points = enclosures
      unless enclosured_points.empty?
        raise GameError, "#{piece.inspect} on row: #{row}, col: #{col} enclosures: #{enclosures.inspect}"
      end
      true
    end

    def undo random: false
      raise GameError, "History empty! Nothing to undo." if @history.empty?
      piece, action = @history.send(random ? :sample! : :pop)
      action.each do |row, col|
        take_out row, col
      end
      @pieces.push << piece
      puts "#{piece.inspect} is back to pieces. now it's #{@pieces.length}"
      piece
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

    def fill row, col
      raise GameError, "Can't fill. Spot busy on row: #{row}, col: #{col}" if spot_busy? row, col
      @fill[row][col] = true
    end

    def take_out row, col
      raise GameError, "Can't take out. Spot empty on row: #{row}, col: #{col}" unless spot_busy? row, col
      @fill[row][col] = false
    end
  end
end