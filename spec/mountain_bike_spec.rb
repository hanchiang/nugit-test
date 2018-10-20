require 'spec_helper'

RSpec.describe MountainBike do
  
  describe '#getAnswer' do
    it 'Should print no result for 0x0 map' do
      # Trivial cases: empty, 1x1
      mb = MountainBike.new({file: '0x0_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('File is empty. Exiting...')
    end

    it 'Should print answer correctly for 1x1 map' do
      mb = MountainBike.new({file: '1x1_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq(5)
    end

    # Non trivial cases: 1 dimension array input, 2x2 and above
    it 'Should print answer correctly for 1x5 map' do
      mb = MountainBike.new({file: '1x5_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('7-3-1')
    end

    it 'Should print answer correctly for 5x1 map' do
      mb = MountainBike.new({file: '5x1_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('7-5-2')
    end

    it 'Should print answer correctly for 2x2 map' do
      mb = MountainBike.new({file: '2x2_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('8-2')
    end

    it 'Should print answer correctly for 2x5 map' do
      mb = MountainBike.new({file: '2x5_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('7-4-1')
    end

    it 'Should print answer correctly for 5x2 map' do
      mb = MountainBike.new({file: '5x2_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('9-8-7-6-2-1')
    end

    it 'Should print answer correctly for 3x3 map' do
      mb = MountainBike.new({file: '3x3_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('8-5-4-1')
    end

    it 'Should print answer correctly for 4x4 map' do
      mb = MountainBike.new({file: '4x4_map.txt'})
      mb.work()
      result = mb.getAnswer()
      expect(result).to eq('9-5-3-2-1')
    end

  end
end