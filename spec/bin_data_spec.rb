require 'bin_data'

RSpec.describe BinData do
  describe ".bit_ranges" do
    it "returns a list of ranges" do
      expect(BinData.bit_ranges([12, 12])).to eq([0...12, 12...24])
    end
  end
end
