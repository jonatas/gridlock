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
    a = GridLock::Pieces::A
    rotated_a = GridLock::Pieces.rotate(a)
    expect(a).to eq([GridLock::CROSS,GridLock::CIRCLE])
    expect(rotated_a).to eq([[GridLock::CROSS],[GridLock::CIRCLE]])
    rotated_a_again = GridLock::Pieces.rotate(rotated_a)
    expect(rotated_a_again).to eq([GridLock::CIRCLE,GridLock::CROSS])
  end

end
