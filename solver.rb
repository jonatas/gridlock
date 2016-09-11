require "./gridlock"
module GridLock
  class Solver
    def self.learn game, solution, pieces
      mind = Hash.new(){|h,k| h[k] = [] }
      solution.each_with_index.map do |piece_name,i|
        piece = pieces[i]
        game.navigate do |row, col|
          begin
            break if piece.nil? || game.finished? 
            game.status(piece: piece, row: row, col: col)
            piece_fit =
              if game.fit? piece, row, col
                piece
              elsif (r1= GridLock::Piece.rotate(piece)) && game.fit?(r1, row, col)
                r1
              elsif (r2= GridLock::Piece.rotate(r1)) && game.fit?(r2, row, col)
                r2
              elsif (r3= GridLock::Piece.rotate(r2)) && game.fit?(r3, row, col)
                r3
              end
            if piece_fit
              space = []
              game.navigate_on piece, row, col do |_row, _col|
                space << [_row, _col]
              end
              mind[piece_name].push [piece_fit, space]
            end
          end
        end
      end
      mind.each{|_,v|v.uniq!}
      mind
    end
    def self.overlap mind
      overlap = Hash.new(){|h,k| h[k] = []}
      mind_set = mind.map{|k,v|[k,v.map(&:last)]}
      mind_set.each do |piece_name, positions|
        mind_set.each do |_piece_name, _positions|
          next if piece_name == _piece_name
          positions.each_with_index do |position, index|
            # TODO: discard overlaps over filled positions from current game
            _index = _positions.index{|e|((position - e) + (e - position)).empty?}
            next unless _index
            overlap[position] << {piece_name => index, _piece_name => _index}
          end
        end
      end
      overlap.each{|_,v|v.uniq!}
      overlap
    end

    def self.run game
      while !game.finished?
        begin
        game.free_positions.sample!
        rescue GameError
          puts "Ops! #{$!}", $@
          game.print_game
          game.undo
          rand(game.enclosures.length + 1).times {  game.undo random: true }
        end
      end
    end
  end
end

begin
  solution, pieces_set = GridLock.ramdom_solution
  game = GridLock::Game.new  pieces_set
  mind = GridLock::Solver.learn game, solution, pieces_set
  overlap = GridLock::Solver.overlap mind
  require "pry"
  binding.pry
  #GridLock::Solver.run game, mind
rescue
  puts $!,$@
  puts "Interrupted after #{Time.now - game.started_at} seconds."
  puts "playing with #{solution}"
ensure
  puts "game finished? #{game.finished?} in #{Time.now - game.started_at} seconds.", game.inspect
  game.status
  p game
end