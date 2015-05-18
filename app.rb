require 'rubygems'
require 'savon'
require 'nokogiri'
require 'sinatra'

get "/lexis_nexis" do
  erb :lexis_nexis
end

post "/upload" do

client = Savon.client(basic_auth: ["PPBRXML", "Bp72jK3u"], wsdl: "https://wsonline.seisint.com/WsIdentity?ver_=1.85&wsdl")
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
      "Middle" => params[:middle_name],
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
      "PostalCode" => params[:postal_code]
    },
    "DOB" => {
      "Year" => params[:year],
      "Month" => params[:month],
      "Day" => params[:day]
    },
    "SSN" => params[:ssn],
    "HomePhone" => params[:phone]
   }
  
  })

r = r.to_s
xml = Nokogiri::XML(r)
xml.remove_namespaces!
transaction_id = xml.xpath('//TransactionId').text
puts "Transaction id = #{transaction_id}"
if ((xml.xpath('//VerifiedElementSummary/DOB').text ) == "1") 
  puts "DOB MATCH => TRUE"
else 
  puts "DOB MATCH => FALSE"
end
if ((xml.xpath('//SSNDeceased').text) == "1") 
  puts "SSN DECEASED = TRUE"
else 
  puts "SSN DECEASED = FALSE"
end
a = xml.xpath('//Description').each do |node|  puts "ERROR: #{node.text}" end 
end



