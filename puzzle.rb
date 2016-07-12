
module GridLock

  module Symbols
    CROSS = "✚"
    SQUARE = "▢"
    CIRCLE = "◯"
  end

  module Pieces
    include GridLock::Symbols

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
end
p GridLock::Pieces::A
p GridLock::Pieces::G