require "./gridlock"

RSpec.describe GridLock do

  it "has symbols" do
    expect(GridLock::Symbols).to include([GridLock::CROSS, GridLock::SQUARE, GridLock::CIRCLE])
  end
  it "has pieces with symbols" do
    expect(GridLock::Pieces::All).to include(GridLock::Pieces::A)
  end

  it "has a default board" do
    expect(GridLock::Board).to be_a(Array)
  end

end
