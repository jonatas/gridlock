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

  context "rotate" do
    let(:piece) { GridLock::Pieces::A }

    let(:rotated_1) { GridLock::Pieces.rotate(piece)     } # 90º
    let(:rotated_2) { GridLock::Pieces.rotate(rotated_1) } # 180º
    let(:rotated_3) { GridLock::Pieces.rotate(rotated_2) } # 270º
    let(:rotated_4) { GridLock::Pieces.rotate(rotated_3) } # 360º -> original piece

    context "one dimension" do

      it("original") { expect(piece).to eq( [GridLock::CROSS, GridLock::CIRCLE]) }

      it "90º" do
        expect(rotated_1).to eq( [
          [GridLock::CROSS],
          [GridLock::CIRCLE]
        ])
      end 

      it("180º") { expect(rotated_2).to eq( [ GridLock::CIRCLE, GridLock::CROSS ] ) }

      it "270º" do
        expect(rotated_3).to eq( [
          [GridLock::CIRCLE],
          [GridLock::CROSS]
        ])
      end
      it("360º is eq 0º"){  expect(rotated_4).to eq( piece ) }
    end

    context "two dimensions" do
      let(:piece) { GridLock::Pieces::H }

      it "original" do
        expect(piece).to eq( [
          [GridLock::CROSS, GridLock::CIRCLE],
          GridLock::SQUARE
        ])
      end

      it "90º" do
        expect(rotated_1).to eq( [
          [GridLock::SQUARE, GridLock::CROSS],
          [             nil, GridLock::CIRCLE],
        ])
      end

      it "180º" do
        expect(rotated_2).to eq( [
          [             nil, GridLock::SQUARE],
          [ GridLock::CIRCLE, GridLock::CROSS],
        ])
      end

      it "270º" do
        expect(rotated_4).to eq( [
          [GridLock::CROSS, GridLock::CIRCLE],
          [GridLock::SQUARE, nil]
        ])
      end
    end
  end

  context 'print board' do
    let(:game) { GridLock::Game.new }
    it "print the board" do

      expect { game.print_game }.to output( %{Game started
▢ ✚ ◯ ◯
◯ ▢ ▢ ✚
✚ ✚ ◯ ✚
✚ ▢ ◯ ▢
✚ ▢ ✚ ✚
◯ ▢ ◯ ◯
◯ ◯ ▢ ▢
}).to_stdout
    end
  end
end
