require "./gridlock"
module GridLock
  class Solver
    def self.run
      game = GridLock::Game.new GridLock.ramdom_solution
      game.print_game
 #     game.debug!
      accepted = false 
      while !game.finished? && !game.pieces.empty?
        piece = game.get_piece!
        if piece.nil?
          puts "pieces is over \o/ but game finished? #{game.finished?}"
          break
        end
        positions = game.free_positions
        accepted = false
        while (piece && !((row,col) = positions.sample!).nil?) && !game.finished?
          begin
            break if piece.nil?
            game.status(piece: piece, row: row, col: col)
            if game.fit? piece, row, col
              piece = nil
            elsif (r1= GridLock::Piece.rotate(piece)) && game.fit?(r1, row, col)
              game.put! r1, row, col
              piece = nil
            elsif (r2= GridLock::Piece.rotate(r1)) && game.fit?(r2, row, col)
              game.put! r2, row, col
              piece = nil
            elsif (r3= GridLock::Piece.rotate(r2)) && game.fit?(r3, row, col)
              game.put! r3, row, col
              piece = nil
            end
          rescue GameError
            puts "Ops! #{$!}", $@
            game.print_game
            rand(game.enclosures.length + 2).times { piece = nil ; game.undo random: true }
          end
          if game.lookups % 1000 == 0
            game.undo while !game.history.empty?
          elsif game.pieces.length < 3 && game.lookups % 500 == 0
            rand(12-game.pieces.length).to_i.times { game.undo random: true }
          end
        end
        puts("no pieces") and break if game.pieces.empty?
      end
      puts "game finished? #{game.finished?} in #{Time.now - game.started_at} seconds.", game.inspect
    rescue
      puts $!,$@
      puts "game finished? #{game.finished?}"
      p game
      puts "Interrupted after #{Time.now - game.started_at} seconds."
    end
  end
end

GridLock::Solver.run