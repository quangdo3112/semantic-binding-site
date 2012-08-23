#! /usr/bin/ruby -Ku
require 'find'
require 'pp'

root = "../material_DAT/BindingSiteDat"
find_entries = Array.new
Find.find(root) do |path|
	find_entries.push(path)
end

$i = 0
$filename = ""
$out_fname = ""
$size = find_entries.size - 1
f = open('../result_DAT/BindingSiteDat.csv', "w")

for $i in 1..$size do
	$filename = find_entries[$i]
	p $filename
	$cnt = 0
	$pmid = ""

	IO.foreach($filename) do |s|
		if $cnt == 2 then
			$pmid = s[16..19]
			$pmid.upcase!
		end
		if $cnt == 5 then
			s.chop!.chop!
			s.gsub!("\$", ",")
			header = s.sub!("Header", "PMID")
			p header
#			f.puts header
		end
#=begin
		if $cnt >= 6 then
			s[0, 1] = ""
			s.chop!.chop!
			s.gsub!("\$", ",")

			s.sub!("Alanine", "ALA")
			s.sub!("Cysteine", "CYS")
			s.sub!("Aspartic Acid", "ASP")
			s.sub!("Glutamic Acid", "GLU")
			s.sub!("Phenylalanine", "PHE")
			s.sub!("Glycine", "GLY")
			s.sub!("Histidine", "HIS")
			s.sub!("Isoleucine", "ILE")
			s.sub!("Lysine", "LYS")
			s.sub!("Leucine", "LEU")
			s.sub!("Methionine", "MET")
			s.sub!("Asparagine", "ASN")
			s.sub!("Proline", "PRO")
			s.sub!("Glutamine", "GLN")
			s.sub!("Arginine", "ARG")
			s.sub!("Serine", "SER")
			s.sub!("Threonine", "THR")
			s.sub!("Valine", "VAL")
			s.sub!("Tryptophan", "TRP")
			s.sub!("Tyrosine", "TYR")
			p csv = $pmid + "," + s
			f.puts csv
		end
#=end
		$cnt += 1
	end
end
