require "./gridlock"

class Array
  def sample!
    delete_at rand length
  end
end
module GridLock
  class Solver

    def self.run
      game = GridLock::Game.new
      game.print_game
      accepted = false 
      pieces = GridLock.ramdom_solution
      while !game.finished?
        piece = pieces.sample!
        if piece.nil?
          puts "pieces is over \o/ but game finished? #{game.finished?}"
          break
        end
        (GridLock::Board.size).times do |x|
          (GridLock::Board[0].size).times do |y|
            if game.fit? piece, x, y
              game.put! piece, x, y
              next
            elsif (r1= GridLock::Pieces.rotate(piece)) && game.fit?(r1, x, y)
              game.put! r1, x, y
              next
            elsif (r2= GridLock::Pieces.rotate(r1)) && game.fit?(r2, x, y)
              game.put! r2, x, y
              next
            elsif (r3= GridLock::Pieces.rotate(r2)) && game.fit?(r3, x, y)
              game.put! r3, x, y
              next
            end
            return if game.finished?
          end
          accepted = false
        end
      end
      puts "game finished? #{game.finished?}"
      p game
    end
  end
rescue
  puts "game finished? #{game.finished?}"
  p game
end

GridLock::Solver.run