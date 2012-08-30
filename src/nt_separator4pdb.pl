#! /usr/bin/perl
use warnings;
use strict;
my $file_name = "../result_DAT/PDBrdf.nt";
my $in; my $out;
my $cnt=0; my $file_cnt=0;
my $i=0;
my $out_file ="";

open($in, "<", $file_name);
for($i=0, $i<=$file_cnt, $i++){

  while(my $line = readline $in){
   chomp($line);
    if($cnt<1000000){
      my $out_file ="../result_DAT/pdb_nt/PDBrdf_DATA_part$file_cnt.nt";
      open($out, ">>", $out_file);
#      print "$out_file,$cnt,$line\n";
      print $out "$line\n";
    }
    elsif($cnt=1000000){
     $cnt=0;
      $file_cnt++;
      my $out_file ="../result_DAT/pdb_nt/PDBrdf_DATA_part$file_cnt.nt";
      open($out, ">>", $out_file);
#      print "$out_file\n";
#      print "$out_file,$cnt,$line\n";
      print $out "$line\n";
   }
    $cnt++;
  }
  close $out;
}
close $in;
