require 'oystercard'

describe Oystercard do
  let(:card) { described_class.new }
  let(:entry_station) { double }
  let(:exit_station) { double }
  let(:top_up_amount) { 20 }

  describe "#balance" do
    it "begins with a default balance of 0" do
      expect(card.balance).to eq(0)
    end
  end

  describe "#top_up" do
    it "top_up changes the balance" do
      expect{card.top_up(top_up_amount)}.to change{card.balance}.by(top_up_amount)
    end

    it "will not top_up when the balance would be over £#{described_class::MAX_MONEY}" do
      message = "Top up would put value over the maximum: £#{described_class::MAX_MONEY}."
      expect{card.top_up(described_class::MAX_MONEY + 1)}.to raise_error(message)
    end
  end

  describe "#touch_in" do
    before(:each) do
      card.top_up(top_up_amount)
    end

    it "responds to touch_in method" do
      expect(card).to respond_to(:touch_in)
    end
  end

  describe "#touch_in_errors" do
    it "raises an error when minimum amount not reached" do
      message = "Minimum balance of £#{described_class::MIN_MONEY} not reached"
      expect{card.touch_in(entry_station)}.to raise_error(message)
    end
  end

  describe "#touch_out" do
    before(:each) do
      card.top_up(top_up_amount)
    end

    it "deducts minimum fare on touch_out" do
      card.touch_in(entry_station)
      expect{card.touch_out(exit_station)}.to change{card.balance}.by(-described_class::MINIMUM_FARE)
    end
  end

  describe "#penalty_charge", :p do
    it "checks penalty charge is set to 6" do
      expect(described_class::PENALTY_CHARGE).to eq(6)
    end

    context "charges penalty fare on following conditions:" do
      before(:each) do
        card.top_up(top_up_amount)
      end
      it "touch out but no touch in" do
        # NOT TOUCHING IN
        expect{card.touch_out(exit_station)}.to change{card.balance}.by(-described_class::PENALTY_CHARGE)
      end

      it "touch in without having previously touched out (touching in twice in a row)" do
        # TOUCHING IN TWICE WITHOUT A TOUCH OUT BETWEEN THEM
        card.touch_in(entry_station)
        expect{card.touch_in(entry_station)}.to change{card.balance}.by(-described_class::PENALTY_CHARGE)
      end
    end
  end
end
