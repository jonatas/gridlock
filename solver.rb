require "./gridlock"

module GridLock
  class Solver
    def self.run
      
      game = GridLock::Game.new
      pieces = GridLock::Pieces::All
      game.print_game
      rotated = 0
      accepted = false 
      solutions = %w(AABCDDEFGIKN ABCDDEFFGJKM ABCCDEFFIJMN ABDDEEFFIKMN ABBCDEFFIJKM ABBCCCDFIJKM ABBCCCDDEFFJK)
      pieces = solutions.sample.split("").map{|piece|Object.const_get("GridLock::Pieces::#{piece}")}
      while !game.finished?
        piece = pieces.pop
        (GridLock::Board.size - 1).times do |x|
          (GridLock::Board[0].size - 1).times do |y|
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
          end
          accepted = false
        end
      end
    end
  end
end

GridLock::Solver.run