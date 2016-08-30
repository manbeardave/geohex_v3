require "#{File.expand_path(File.dirname(__FILE__))}/../lib/geohex.rb"
require "pp"
require "pry"
require "csv"
require "json"
include GeoHex

describe GeoHex do
  before(:all) {
    
    @test_xy_to_hex = []
    
    CSV.open("#{File.expand_path(File.dirname(__FILE__))}/fixture_getZoneByXY.csv").each do |l|
      if l.slice(0,1) != "#"
        d = l
        @test_xy_to_hex << [d[0],d[1].to_f, d[2].to_f,d[3]]
      end
    end
  
    test_coord2XY  = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_coord2XY.json")
    @test_ll_to_xy = JSON.parse(test_coord2XY) 
    
    
    test_coord2Hex  = File.read("#{File.expand_path(File.dirname(__FILE__))}/hex_v3.2_test_coord2HEX.json")   
    @test_coord2Hex = JSON.parse(test_coord2Hex)
  }
  
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
    @test_xy_to_hex.each do |v|
      expect(GeoHex::Zone.getZoneByXy(v[1],v[2],v[0].to_i).code).to eq(v[3])
    end
  end
  
  it "should return XY from lat long" do
    @test_ll_to_xy.each do |v|
      expect(GeoHex::Zone.getXYByLocation(v[1],v[2],v[0].to_i)).to eq({x: v[3], y: v[4]})
    end
  end
  
  it "should return Zone from location" do
    @test_coord2Hex.each do |v|
      expect(GeoHex::Zone.getZoneByLocation(v[1],v[2],v[0].to_i).code).to eq(v[3])
    end
  end
  
end
