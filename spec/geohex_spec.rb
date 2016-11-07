require "#{File.expand_path(File.dirname(__FILE__))}/../lib/geohex.rb"
require "pp"
require "pry"
require "csv"
require "json"
include GeoHex

describe GeoHex do
  it "should throw error if parameters is not valid" do
    lambda { GeoHex::Zone.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex::Zone.encode(-86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(85,181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(-85,-181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(0,180,-1) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex::Zone.encode(0,-180,25) }.should raise_error(ArgumentError) # invalid level
  end
  
  
  it "should return code from XY" do
    @test_xy_to_hex = []    
    CSV.open("#{File.expand_path(File.dirname(__FILE__))}/fixture_getZoneByXY.csv").each do |l|
      if l.slice(0,1) != "#"
        d = l
        @test_xy_to_hex << [d[0],d[1].to_f, d[2].to_f,d[3]]
      end
    end
    @test_xy_to_hex.each do |v|
      expect(GeoHex::Zone.getZoneByXy(v[1],v[2],v[0].to_i).code).to eq(v[3])
    end
  end
  
  it "should return XY from lat long" do
    test_coord2XY  = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_coord2XY.json")
    @test_ll_to_xy = JSON.parse(test_coord2XY) 
    @test_ll_to_xy.each do |v|
      expect(GeoHex::Zone.getXYByLocation(v[1],v[2],v[0].to_i)).to eq({x: v[3], y: v[4]})
    end
  end
  
  it "should return Zone from location" do
    test_coord2Hex  = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_coord2HEX.json")   
    @test_coord2Hex = JSON.parse(test_coord2Hex)
    @test_coord2Hex.each do |v|
      expect(GeoHex::Zone.getZoneByLocation(v[1],v[2],v[0].to_i).code).to eq(v[3])
    end
  end
  
  it "should return XY from code" do
    test_code2XY    = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_code2XY.json")
    @test_code2XY   = JSON.parse(test_code2XY)
    
    @test_code2XY.each do |v|
      expect(GeoHex::Zone.getXYByCode(v[0])).to eq({x: v[1], y: v[2]})
    end
  end
  
  it "should return XY from code" do
    test_code2Hex    = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_code2HEX.json")
    @test_code2Hex   = JSON.parse(test_code2Hex)
    
    @test_code2Hex.each do |v|
      zone = GeoHex::Zone.getZoneByCode(v[0])
      expect(zone.lat).to eq(v[1])
      expect(zone.lon).to eq(v[2])
    end
  end
  
  
  it "should have consistent results for the readme examples" do    
    expect(GeoHex::Zone.getZoneByLocation(33.127120,-117.3274073, 11).code).to eq 'PC22751337146'
    x = GeoHex::Zone.getZoneByCode('PC22751337146')
    binding.pry
    expect(x.x).to eq -250028
    expect(x.y).to eq 789182
  end
    
end
