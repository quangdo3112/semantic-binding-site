#! /usr/bin/ruby -Ku

require 'find'
require 'rexml/document'
include REXML

=begin
xml = open("../material_DAT/BindingSiteDat/XML/102l.pdb.xml") {|f| f.read}
xml.force_encoding("utf-8")
doc = REXML::Document.new(xml)
#puts doc
p REXML::XPath.match( doc, "//methodname/text()" )
=end


#=begin
root = "../material_DAT/BindingSiteDat/XML"
find_entries = Array.new
Find.find(root) do |path|
	find_entries.push(path)
end

$i = 0
$filename = ""
$out_fname = ""
$size = find_entries.size - 1

#f = open("../result_DAT/NMR_PDBID_List")

for $i in 1..$size do
	$filename = find_entries[$i]
	p $filename


	xml = open($filename) {|f| f.read}
	xml.force_encoding("utf-8")
	doc = REXML::Document.new(xml)
	#puts doc

	methodname =  REXML::XPath.match( doc, "//methodname/text()" )
	p methodname
	
end


#f.close
#=end




