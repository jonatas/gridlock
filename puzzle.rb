
module GridLock

  CROSS = "✚"
  SQUARE = "▢"
  CIRCLE = "◯"

  module Pieces

    A = [CROSS,  CIRCLE]
    B = [CROSS,  SQUARE]
    C = [SQUARE, CIRCLE]
    D = [CROSS,  CROSS ]
    E = [SQUARE, SQUARE]
    F = [CIRCLE, CIRCLE]

    G = [[SQUARE, CIRCLE], SQUARE]
    H = [[CROSS,  CIRCLE], SQUARE]
    I = [[CIRCLE, SQUARE], CROSS ]
    J = [[CROSS,  CROSS ], SQUARE]
    K = [[CIRCLE, CIRCLE], SQUARE]
    L = [[SQUARE, CIRCLE], CIRCLE]
    M = [[CROSS,  SQUARE], CIRCLE]
    N = [[SQUARE, CROSS ], CIRCLE]

  end

  BOARD = [
    [ SQUARE,  CROSS, CIRCLE, CIRCLE ],
    [ CIRCLE, SQUARE, SQUARE,  CROSS ],
    [  CROSS,  CROSS, CIRCLE,  CROSS ],
    [  CROSS, SQUARE, CIRCLE, SQUARE ],
    [  CROSS, SQUARE,  CROSS,  CROSS ],
    [ CIRCLE, SQUARE, CIRCLE, CIRCLE ],
    [ CIRCLE, CIRCLE, SQUARE, SQUARE ]
  ]
end