#! /usr/bin/ruby -Ku
#
#  nmrsearch.rb extract PDBID of NMR method from Saad's XML file. 
#
require 'find'
require 'rexml/document'
include REXML

root = "../material_DAT/BindingSiteDat/XML"
find_entries = Array.new
Find.find(root) do |path|
	find_entries.push(path)
end

$i = 0
$filename = ""
$size = find_entries.size - 1


File.open("../result_DAT/NMR_PDBID_List.txt", "w") do |f1|
File.open("../result_DAT/X-RAY_PDBID_List.txt", "w") do |f2|
File.open("../result_DAT/Other_PDBID_List.txt", "w") do |f3|

for $i in 1..$size do
	$filename = find_entries[$i]
	#p $filename


	xml = open($filename) {|f| f.read}
	xml.force_encoding("utf-8")
	doc = REXML::Document.new(xml)
	#puts doc

	methodname =  REXML::XPath.match( doc, "//methodname/text()" )
	#p methodname

	if methodname == ["SOLUTION NMR"] then
		pdbid = $filename[35..38]
		print pdbid, ","
		puts methodname
		f1.puts pdbid	
	elsif methodname == ["X-RAY DIFFRACTION"] then
		pdbid = $filename[35..38]
		print pdbid, ","
		puts methodname
		f2.puts pdbid
	else
		pdbid = $filename[35..38]
		print pdbid, ","
		puts methodname
 		f3.print pdbid , "," , methodname, "\n"
	end
end

end
end
end

