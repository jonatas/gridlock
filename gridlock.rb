module GridLock

  Symbols = [
    CROSS = '✚'.freeze,
    SQUARE = '▢'.freeze,
    CIRCLE = '◯'.freeze
  ].freeze

  def self.solutions
    %w[
      AABBCCDFGIJK AABBCCDFGJLN AABBCCCDEFFIJ AABBCCCDEFFJN AABBCCCDJKLM
      AABBCCCDDEFHK AABBFGIJKMN AABBBCFFGJMN AABBBCCCDDFGL AAABCCDEEFFIJ
      AAABCCDEEFFHJ AAABCDDEEFFGN AAABCCDDEEFKM AAABBCEFJKMN AAABBEFFGJMN
      AAABBBCCCDFGH AAABBBCCEFFIJ AAABCDEFGIMN AAABCCDDEEFHL AAABCCCDGIJL
      AAABBCEFIJKM AAABBCCCDDEEFF AAABBCCDGHKM AAAABBCCDEFGI AAACCCDEIJLN
      AAABBCCCIJLN AAAABCCDEEFHM AAAABCCDEEFIM AAAABBBCCCFGJ AAAABBBCCDEEFF
    ].each_with_object({}) { |e, h| h[e] = e.split('').map { |piece| Object.const_get("GridLock::Piece::#{piece}") } }
  end

  def self.ramdom_solution
    key = solutions.keys.sample
    [key, solutions[key]]
  end

  def self.get_pieces_for(solution)
    solution
  end

  module Piece

    All = [

      A = [CROSS,  CIRCLE].freeze,
      B = [CROSS,  SQUARE].freeze,
      C = [SQUARE, CIRCLE].freeze,
      D = [CROSS,  CROSS].freeze,
      E = [SQUARE, SQUARE].freeze,
      F = [CIRCLE, CIRCLE].freeze,

      G = [[SQUARE, CIRCLE], SQUARE].freeze,
      H = [[CROSS, CIRCLE], SQUARE].freeze,
      I = [[CIRCLE, SQUARE], CROSS].freeze,
      J = [[CROSS, CROSS], SQUARE].freeze,
      K = [[CIRCLE, CIRCLE], SQUARE].freeze,
      L = [[CIRCLE, SQUARE], CIRCLE].freeze,
      M = [[CROSS, SQUARE], CIRCLE].freeze,
      N = [[SQUARE, CROSS], CIRCLE].freeze

    ].freeze

    def self.multidimensional?(piece)
      piece.any? { |e| e.is_a?(Array) && e.compact.length > 1 }
    end

    def self.rotations(piece)
      if multidimensional? piece
        [piece,
         r1 = rotate(piece),
         r2 = rotate(r1),
         rotate(r2)]
      else
        [
          piece,
          [[piece[0]], [piece[1]]],
          piece.reverse,
          [[piece[1]], [piece[0]]]
        ]
      end
    end

    def self.rotate(piece)
      [
        [piece[1][0], piece[0][0]],
        ([piece[1][1], piece[0][1]] if piece[1][1] || piece[0][1])
      ].compact
    end

    def self.string_for_multidimensional(piece)
      piece.map do |row|
        row = [row] unless row.is_a? Array
        row.map { |e| e || ' ' }.join(' ')
      end
    end

    def self.string_for_simple(piece)
      if piece[0].is_a? String
        [piece.join(' '), '']
      else
        piece
      end
    end

    def self.print(piece)
      method = multidimensional?(piece) ? :string_for_multidimensional : :string_for_simple
      puts public_send(method, piece)
    end
  end

  Board = [
    [SQUARE, CROSS, CIRCLE, CIRCLE],
    [CIRCLE, SQUARE, SQUARE, CROSS],
    [CROSS, CROSS, CIRCLE,  CROSS],
    [CROSS, SQUARE, CIRCLE, SQUARE],
    [CROSS, SQUARE, CROSS, CROSS],
    [CIRCLE, SQUARE, CIRCLE, CIRCLE],
    [CIRCLE, CIRCLE, SQUARE, SQUARE]
  ].freeze

  class GameError < StandardError
  end

  class Game
    attr_reader :history, :cols, :lines, :cursor_hover, :started_at, :pieces, :lookups
    def initialize(pieces: [], board: GridLock::Board)
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

    def spot_busy?(row, col)
      @fill[row][col]
    end

    def cursor_hover?(row, col)
      @hover == [row, col]
    end

    def free_positions
      positions = []
      navigate do |row, col|
        next if spot_busy? row, col
        positions << [row, col]
      end
      positions
    end

    def each_symbol_of(piece)
      piece.each_with_index do |symbol, i|
        if symbol.is_a? Array
          symbol.each_with_index do |current_symbol, col|
            yield(current_symbol, i, col) if current_symbol
          end
        elsif symbol
          params = [0, i]
          params.reverse! if GridLock::Piece.multidimensional?(piece)
          yield(symbol, *params)
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

    def around(row, col)
      debug "around(#{row},#{col}) ? if col+1 < @cols:: #{col + 1} < #{@cols}) || if row+1 < @rows :: #{row + 1} < #{@rows}"
      [
        ([row, col - 1] if col > 0),
        ([row - 1, col] if row > 0),
        ([row, col + 1] if col + 1 < @cols),
        ([row + 1, col] if row + 1 < @rows)
      ].compact
    end

    def enclosures
      navigate do |row, col|
        next if spot_busy? row, col
        [row, col] if enclosured? row, col
      end
    end

    def enclosured?(row, col)
      debug "enclosured?: row: #{row}, col: #{col} #{around(row, col).inspect}"
      found = around(row, col).all? do |(current_row, current_col)|
        busy = spot_busy?(current_row, current_col)
        debug("spot_busy?(#{current_row},#{current_col}) # => #{busy}")
        busy
      end
      debug "? row: #{row}, col: #{col}, found enclosured?: #{found}"
      found
    end

    def out_of_board?(current_row, current_col)
      current_row > @rows - 1 || current_col > @cols - 1
    end

    def match?(piece, row, col)
      debug "match? #{piece.inspect}, row: #{row}, col: #{col}"
      navigate_on(piece, row, col) do |current_symbol, current_row, current_col|
        debug "> match? #{current_symbol}, current_row: #{current_row}, current_col: #{current_col}"
        return false if out_of_board? current_row, current_col
        return false if current_symbol != GridLock::Board[current_row][current_col]
      end
      true
    end

    def finished?
      @fill.all? { |row| row.all? & :true? }
    end

    def hover(row, col)
      @hover = [row, col]
      yield
      @hover = []
    end

    def fit?(piece, row = 0, col = 0)
      @lookups += 1
      fit = true
      hover(row, col) do
        navigate_on piece, row, col do |_, current_row, current_col|
          if out_of_board?(current_row, current_col) || spot_busy?(current_row, current_col)
            fit = false
            break
          end
        end
        fit = false unless match?(piece, row, col)
      end
      fit
    end

    def status(col: nil, row: nil, piece: nil)
      puts "\e[H\e[2J",
           "loop: #{@lookups}, row: #{row}, col: #{col}), pieces: #{@pieces.length}\n"
      GridLock::Piece.print(piece)
      print_game
    end

    def navigate_on(piece, row, col)
      each_symbol_of piece do |current_symbol, r, c|
        yield(current_symbol, row + r, col + c)
      end
    end

    def remove_from_pieces!(piece)
      if (index = @pieces.index { |current_piece| GridLock::Piece.rotations(current_piece).include?(piece) })
        @pieces.delete_at(index)
      end
    end

    def add_on_history!(piece, row, col)
      @history << [piece, []]
      navigate_on piece, row, col do |_, current_row, current_col|
        fill(current_row, current_col)
        @history.last.last << [current_row, current_col]
      end
    end

    def put!(piece, row, col)
      fail GameError, "piece: #{piece.inspect} does not fit on row: #{row}, col: #{col}" unless fit? piece, row, col
      status(row: row, col: col, piece: piece)
      remove_from_pieces! piece
      add_on_history! piece, row, col
      fail GameError, "#{piece.inspect} on row: #{row}, col: #{col} enclosures: #{enclosures.inspect}" unless enclosures.empty?
      true
    end

    def undo(random: false)
      fail GameError, 'History empty! Nothing to undo.' if @history.empty?
      piece, action = @history.public_send(random ? :sample! : :pop)
      action.each do |row, col|
        take_out row, col
      end
      @pieces.push << piece
      puts "#{piece.inspect} is back to pieces. now it's #{@pieces.length}"
      piece
    end

    def debug(message)
      puts message if @debug
    end

    def debug!
      @debug = true
    end

    def fill(row, col)
      fail GameError, "Can't fill. Spot busy on row: #{row}, col: #{col}" if spot_busy? row, col
      @fill[row][col] = true
    end

    def take_out(row, col)
      fail GameError, "Can't take out. Spot empty on row: #{row}, col: #{col}" unless spot_busy? row, col
      @fill[row][col] = false
    end

    def color_for(row, col)
      return :red if spot_busy?(row, col)
      return :purple if cursor_hover?(row, col)
      :green
    end

    def print_game(color: true)
      print "\n"
      GridLock::Board.each_with_index.map do |line, line_index|
        line.each_with_index.map do |spot, column_index|
          if color
            Output.public_send(color_for(line_index, column_index), spot)
          else
            print spot
          end
          print(' ') if column_index < line.size - 1
        end
        puts
      end
    end
  end
end

class Output
  class << self
    def colorize(str, color_code)
      print "\e[#{color_code}m#{str}\e[0m"
    end

    def red(str)
      colorize(str, 31)
    end

    def green(str)
      colorize(str, 32)
    end

    def purple(str)
      colorize(str, 35)
    end
  end
end
class Array
  def sample!
    delete_at rand length
  end
end
