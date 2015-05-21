require 'rubygems'
require 'savon'
require 'nokogiri'
require 'sinatra'
require 'pry'
require 'nori'
require 'rest-client'

get "/lexis_nexis" do
  erb :lexis_nexis
end

post "/upload" do

client = Savon.client(basic_auth: ["PPBRDEVXML", "Test0005"], wsdl: "https://wsonline.seisint.com/WsIdentity?ver_=1.85&wsdl", raise_errors: false, proxy: "http://quotaguard2753:81a044322cd6@us-east-1-static-brooks.quotaguard.com:9293")

r = client.call( :flex_id, message: {
     "Options" => {
       "WatchLists" => "OFAC",
       "RequireExactMatch" => {
          "LastName" => "true",
          "FirstName" => "true",
          "Address" => "true"
    }
   },
   "SearchBy" => {
     "Name" => {
      "First" => params[:first_name],
      "Last" => params[:last_name]
      },
    "Address" => {
      "StreetNumber" => params[:st_num],
      "StreePreDirection" => params[:direction],
      "StreetName" => params[:st_name],
      "StreetSuffix" => params[:st_suffix],
      "UnitDesignation" => params[:unit_type],
      "UnitNumber" => params[:unit_num],
      "City" => params[:city],
      "State" => params[:state],
      "Zip5" => params[:postal_code]
    },
    "DOB" => {
      "Year" => params[:year],
      "Month" => params[:month],
      "Day" => params[:day]
    },
    "SSN" => params[:ssn],
    "HomePhone" => params[:phone]
   }
  
  }) do 
  advanced_typecasting true
  response_parser :nokogiri
end

  r = r.to_s 
  parsed = Nori.new.parse(r)
  response = parsed["soap:Envelope"]["soap:Body"]["FlexIDResponseEx"]["response"]
  response["Result"].each do |key,value| "#{key} #{value}" end
end



