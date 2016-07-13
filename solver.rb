require "./gridlock"

module GridLock
  class Solver
    def self.run
      
      game = GridLock::Game.new
      pieces = GridLock::Pieces::All
      game.print_game
      i = 0
      rotated = 0
      accepted = false
      while piece = pieces.sample
        (GridLock::Board.size - 1).times do |x|
          (GridLock::Board[0].size - 1).times do |y|
           i += 1

            begin
              puts "\e[H\e[2J Iteration: #{i}:#{rotated} Piece: #{piece.inspect.send(accepted ? :green : :red)}"
              #puts "Iteration: #{i}:#{rotated} Piece: #{piece.inspect.send(accepted ? :green : :red)}"
              game.print_game
              sleep 0.01
              if game.fit? piece, x, y
                game.put! piece, x, y
                accepted = true
                piece = pieces.sample
                next
              #else
              #  raise "retry ¬¬"
              end
            rescue
              if (rotated += 1) < 4
                piece = GridLock::Pieces.rotate piece
                retry
              else
                rotated = 0
              end
            end
          end
        end
        accepted = false
      end
    end
  end
end
GridLock::Solver.run