require "./gridlock"
class Array
  def sample!
    delete_at rand length
  end
end
module GridLock
  class Solver


    def self.run
      game = GridLock::Game.new GridLock.ramdom_solution
      game.print_game
      accepted = false 
      while !game.finished?
        piece = game.get_piece!
        if piece.nil?
          puts "pieces is over \o/ but game finished? #{game.finished?}"
          break
        end
        positions = game.free_positions
        accepted = false
        while !((row,col) = positions.sample!).nil?
          begin
            if game.fit? piece, row, col
              game.put! piece, row, col
              next
            elsif (r1= GridLock::Piece.rotate(piece)) && game.fit?(r1, row, col)
              game.put! r1, row, col
              accepted = true
              break
            elsif (r2= GridLock::Piece.rotate(r1)) && game.fit?(r2, row, col)
              game.put! r2, row, col
              accepted = true
              break
            elsif (r3= GridLock::Piece.rotate(r2)) && game.fit?(r3, row, col)
              game.put! r3, row, col
              accepted = true
              break
            end

          rescue GameError
            puts "Ops! #{$!}", $@
            game.print_game
            (game.enclosures.length + rand(2) ).times { game.undo unless game.history.empty? }
          end
          return if game.finished?
        end
        sleep 0.01
        game.pieces << piece unless accepted
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