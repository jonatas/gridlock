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

    it("original") { expect(piece).to eq( [GridLock::CROSS, GridLock::CIRCLE]) }

    context "one dimension" do

      it "90º" do
        expect(rotated_1).to eq( [
          [GridLock::CROSS, nil],
          [GridLock::CIRCLE, nil]
        ])
      end 

      it("180º") { expect(rotated_2).to eq( [ GridLock::CIRCLE, GridLock::CROSS ] ) }

      it "270º" do
        expect(rotated_3).to eq( [
          [GridLock::CIRCLE, nil],
          [GridLock::CROSS, nil ]
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

  context 'game' do
    let(:game) { GridLock::Game.new }
    let(:cross_circle) {  [GridLock::CROSS, GridLock::CIRCLE] }
    let(:rotated_cross_circle) {GridLock::Pieces.rotate(cross_circle)}
    let(:square_cross_circle) { [[GridLock::SQUARE, GridLock::CROSS], [GridLock::CIRCLE]] }

    it "print" do
      expect { game.print_game(false) }.to output( %{
▢ ✚ ◯ ◯
◯ ▢ ▢ ✚
✚ ✚ ◯ ✚
✚ ▢ ◯ ▢
✚ ▢ ✚ ✚
◯ ▢ ◯ ◯
◯ ◯ ▢ ▢
}).to_stdout
    end

    context ".match?" do
      it { expect(game.match?(cross_circle, 0, 0)).to be_falsy  }
      it { expect(game.match?(cross_circle, 0, 1)).to be_truthy }
      it { expect(game.match?(square_cross_circle, 0, 0)).to be_truthy }
      it { expect(game.match?(square_cross_circle, 0, 1)).to be_falsy}
      it { expect(game.match?(rotated_cross_circle, 4, 0)).to be_truthy}
      it { expect(game.match?(rotated_cross_circle, 4, 2)).to be_truthy}
      it { expect(game.match?(rotated_cross_circle, 4, 1)).to be_falsy}
    end

    context ".fit?" do
      it 'false when filled' do
        game.fill(0,0)
        expect(game.fit?(cross_circle, 0,0)).to be_falsy
      end

      it 'false when symbol does not match on position' do
        expect(game.fit?(cross_circle, 2,0)).to be_falsy
      end

      it 'when spot is free and match the position' do
        expect(game.fit?(cross_circle, 2,1)).to be_truthy
      end
    end

    context "put!(piece, *position)" do
      it "fill piece positions" do
        game.print_game
        expect(game.put!(cross_circle, 2,1)).to be_truthy
        game.print_game
        expect { game.put!(cross_circle, 2,1) }.to raise_error
      end
    end
  end
end
