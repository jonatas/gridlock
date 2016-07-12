require "./gridlock"

RSpec.describe GridLock do

  it "has symbols" do
    expect(GridLock::Symbols).to include([GridLock::CROSS, GridLock::SQUARE, GridLock::CIRCLE].sample)
  end
  it "has pieces with symbols" do
    expect(GridLock::Pieces::All).to include(GridLock::Pieces::A)
  end

  it "has a default board" do
    expect(GridLock::Board).to be_a(Array)
  end

  it "can rotate pieces" do

    piece = GridLock::Pieces::A

    rotated_1 = GridLock::Pieces.rotate(piece)     # 90º
    rotated_2 = GridLock::Pieces.rotate(rotated_1) # 180º
    rotated_3 = GridLock::Pieces.rotate(rotated_2) # 270º
    rotated_4 = GridLock::Pieces.rotate(rotated_3) # 360º -> original piece

    expect(piece).to     eq([GridLock::CROSS,GridLock::CIRCLE])
    expect(rotated_1).to eq([[GridLock::CROSS],[GridLock::CIRCLE]])
    expect(rotated_2).to eq([GridLock::CIRCLE,GridLock::CROSS])
    expect(rotated_3).to eq([[GridLock::CIRCLE],[GridLock::CROSS]])
    expect(rotated_4).to eq(piece)
  end

end
