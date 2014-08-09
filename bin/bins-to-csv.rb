require 'json'
require 'csv'
require 'rest_client'
require 'cgi'
require 'fileutils'
require 'osgb_convert'

dir = File.dirname(__FILE__)
FileUtils.mkdir_p( File.join(dir, "..", "data") )

MAX_RESULTS= 1000
# in metres
SEARCH_DISTANCE = 20000
# See http://data.ordnancesurvey.co.uk/doc/7000000000025554
BANES_CENTROID_EASTING=366217
BANES_CENTROID_NORTHING=161998

#Returns GeoJSON
ISHARE_URL = "http://isharemaps.bathnes.gov.uk/MapGetImage.aspx"

ISHARE_PARAMS = {
  "Type" => "json",
  "MapSource"=>"BathNES/WinterMaintenance",
  "RequestType" => "GeoJSON",
  "ServiceAction" => "ShowMyClosest",
  "ActiveTool"=>"MultiInfo",
  "ActiveLayer"=>"GritBins",
  "mapid"=>"-1",
  "SearchType"=>"findMyNearest",
  "Distance"=>SEARCH_DISTANCE,
  "MaxResults"=>MAX_RESULTS,
  "Easting"=>BANES_CENTROID_EASTING,
  "Northing"=>BANES_CENTROID_NORTHING
}

response = RestClient.get ISHARE_URL, {:params => ISHARE_PARAMS }
json = JSON.parse( response.body )   

CSV.open( File.join(dir, "..", "data", "banes-gritbins.csv"), "w") do |csv|
  csv << ["Latitude", "Longitude", "Easting", "Northing", "Notes"]
  json[0]["features"].each do |feature|
    notes = CGI.unescapeHTML( feature["properties"]["fields"]["_"].gsub("GBIN: ", "") )
    easting = feature["geometry"]["coordinates"][0].first
    northing = feature["geometry"]["coordinates"][0].last
    location =  OsgbConvert::OSGrid.new( easting, northing )
    wgs84 = location.wgs84
    csv << [ wgs84.lat, wgs84.long, easting, northing, notes ]
  end
end

