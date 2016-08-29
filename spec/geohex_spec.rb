require "#{File.expand_path(File.dirname(__FILE__))}/../lib/geohex.rb"
require "pp"
require "pry"
require "csv"
require "json"
include GeoHex

describe GeoHex do
  before(:all) do
    @test_ll2hex = []
    @test_hex2ll = []
    @test_xy_to_hex = []
    File.open("#{File.expand_path(File.dirname(__FILE__))}/testdata_ll2hex.txt").read.each_line do |l|
      if l.slice(0,1) != "#"
        d = l.strip.split(',')
        @test_ll2hex << [d[0].to_f, d[1].to_f, d[2].to_i, d[3]]
      end
    end
    File.open("#{File.expand_path(File.dirname(__FILE__))}/testdata_hex2ll.txt").read.each_line do |l|
      if l.slice(0,1) != "#"
        d = l.strip.split(',')
        @test_hex2ll << [d[0],d[1].to_f, d[2].to_f,d[3].to_i]
      end
    end
    CSV.open("#{File.expand_path(File.dirname(__FILE__))}/fixture_getZoneByXY.csv").each do |l|
      if l.slice(0,1) != "#"
        d = l
        @test_xy_to_hex << [d[0],d[1].to_f, d[2].to_f,d[3]]
      end
    end
    
    
    file = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_coord2XY.json")
    @test_ll_to_xy = JSON.parse(file)
    
  end  
  
  it "should throw error if parameters is not valid" do
    lambda { GeoHex::Zone.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex::Zone.encode(-86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(85,181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(-85,-181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(0,180,-1) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex::Zone.encode(0,-180,25) }.should raise_error(ArgumentError) # invalid level
  end
  xit "should convert coordinates to geohex code" do
    # correct answers (you can obtain this test variables from jsver_test.html )
    @test_ll2hex.each do |v|
      expect(GeoHex::Zone.encode(v[0],v[1],v[2])).to eq(v[3])
    end
    
  end
  
  
  xit "should convert geohex to coordinates " do
    # correct answers (you can obtain this test variables from jsver_test.html )
    @test_hex2ll.each do |v|
      expect(GeoHex::Zone.decode(v[0])).to eq([v[1],v[2],v[3]])
    end
  end

  xit "should return instance from coordinates " do
    expect(GeoHex::Zone.new(35.647401,139.716911,12).code).to eq 'mbas1eT'
  end

  xit "should raise error if instancing with nil data " do
    lambda { GeoHex::Zone.new }.should raise_error(ArgumentError)
  end

  xit "should return instance from hexcode " do
    geohex = GeoHex::Zone.new('wwhnTzSWp')
    expect(geohex.lat).to eq 35.685262361266446
    expect(geohex.lon).to eq 139.76695060729983
    expect(geohex.level).to eq 22
  end
  
  
  it "should return code from XY" do
    @test_xy_to_hex.each do |v|
      expect(GeoHex::Zone.getZoneByXy(v[1],v[2],v[0].to_i).code).to eq(v[3])
    end
  end
  
  it "should return code from XY" do
    @test_ll_to_xy.each do |v|
      expect(GeoHex::Zone.getXYByLocation(v[1],v[2],v[0].to_i)).to eq({x: v[3], y: v[4]})
    end
  end
end
