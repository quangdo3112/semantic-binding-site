#!/usr/bin/perl
#
# serialize_plbsp_csv2rdf.pl : Serializer for PLBSP
#
# Author : Toyofumi Fujiwara (INTEC Inc.)
# License : CC-•\Ž¦2.1“ú–{
#
use strict;
use warnings;
use utf8;
use RDF::Trine::Model;
use RDF::Trine::Store::Memory;
use RDF::Trine::Serializer::RDFXML;
use RDF::Trine::Serializer::Turtle;
use RDF::Trine::Namespace qw/rdf/;
use RDF::Trine::Parser;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

# make RDF model object
my $serializer = RDF::Trine::Serializer::NTriples->new(
  namespaces => { 
    rdf   => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs  => 'http://www.w3.org/2000/01/rdf-schema#',
    owl   => 'http://www.w3.org/2002/07/owl#',
    PDBo  => 'http://pdbj.org/schema/pdbx-v40.owl#',
    bilab => 'http://www.bi.a.u-tokyo.ac.jp/owl#',
    ddi   => 'http://purl.org/ddi/owl#'
  }
);


###
## bilab Ontology
##  bilab:BSID
##  bilab:has_interact_atom_site
##  bilab:has_interact_chem_comp_atom
###
# PREFIX bilab(http://www.bi.a.u-tokyo.ac.jp/owl#)
my $NS_bilab = RDF::Trine::Namespace->new( 'http://www.bi.a.u-tokyo.ac.jp/owl#' );
# Classes
my $NC_BSID = $NS_bilab->BSID;
# Object Properties
my $NO_has_interact_atom_site = $NS_bilab->has_interact_atom_site;
my $NO_has_interact_chem_comp_atom = $NS_bilab->has_interact_chem_comp_atom;

###
## PDBo Ontology
##  PDBo:PDBID
##  PDBo:atom_site
##  PDBo:chem_comp_atom
##  PDBo:has_atom_site
##  PDBo:has_chem_comp_atom
##  PDBo:atom_site.label_asym_id
##  PDBo:atom_site.label_atom_id
##  PDBo:atom_site.label_comp_id
##  PDBo:atom_site.label_seq_id
##  PDBo:atom_site.Cartn_x
##  PDBo:atom_site.Cartn_y
##  PDBo:atom_site.Cartn_z
##  PDBo:chem_comp_atom.model_Cartn_x
##  PDBo:chem_comp_atom.model_Cartn_y
##  PDBo:chem_comp_atom.model_Cartn_z
##  PDBo:chem_comp_atom.type_symbol
##  PDBo:chem_comp.name
###
# PREFIX PDBo(http://pdbj.org/schema/pdbx-v40.owl#)
my $NS_PDBo = RDF::Trine::Namespace->new( 'http://pdbj.org/schema/pdbx-v40.owl#' );
# Classes
my $NC_PDBID = $NS_PDBo->PDBID;
my $NC_atom_siteCategory = $NS_PDBo->atom_siteCategory;
my $NC_atom_site = $NS_PDBo->atom_site;
my $NC_chem_comp_atomCategory = $NS_PDBo->chem_comp_atomCategory;
my $NC_chem_comp_atom = $NS_PDBo->chem_comp_atom;
# Object Properties
my $NO_has_atom_site = $NS_PDBo->has_atom_site;
my $NO_has_chem_comp_atom = $NS_PDBo->has_chem_comp_atom;
my $NO_atom_site_label_asym_id = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.label_asym_id");
my $NO_atom_site_label_atom_id = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.label_atom_id");
my $NO_atom_site_label_comp_id = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.label_comp_id");
my $NO_atom_site_label_seq_id = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.label_seq_id");
my $NO_atom_site_Cartn_x = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.Cartn_x");
my $NO_atom_site_Cartn_y = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.Cartn_y");
my $NO_atom_site_Cartn_z = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.Cartn_z");
my $NO_atom_site_type_symbol = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#atom_site.type_symbol");
my $NO_chem_comp_atom_model_Cartn_x = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#chem_comp_atom.model_Cartn_x");
my $NO_chem_comp_atom_model_Cartn_y = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#chem_comp_atom.model_Cartn_y");
my $NO_chem_comp_atom_model_Cartn_z = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#chem_comp_atom.model_Cartn_z");
my $NO_chem_comp_atom_type_symbol = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#chem_comp_atom.type_symbol");
my $NO_chem_comp_name = new RDF::Trine::Node::Resource("http://pdbj.org/schema/pdbx-v40.owl#chem_comp.name");

###
## ddi Ontology
##  ddi:distance_to_atom
###
# PREFIX ddi(http://purl.org/ddi/owl#)
my $NS_ddi = RDF::Trine::Namespace->new( 'http://purl.org/ddi/owl#' );
# Object Properties
my $NO_distance_to_atom = $NS_ddi->distance_to_atom;

###
## RDF Schema
###
my $NS_rdf_schema = RDF::Trine::Namespace->new( 'http://www.w3.org/2000/01/rdf-schema#' );
my $NO_label      = $NS_rdf_schema->label;

###
## RDF
###
my $NS_rdf_syntax_ns = RDF::Trine::Namespace->new( 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );
my $NO_type          = $NS_rdf_syntax_ns->type;


##
# Make rdf
##
#my $file_csv = './binding_site_data.csv';
my $file_csv = './plbsp.csv';
my $file_rdf = './plbsp.nt';
my $FH_csv;
my $FH_rdf;
my $store = new RDF::Trine::Store::Memory;
my $model = new RDF::Trine::Model($store);
open($FH_rdf, "> ".$file_rdf) or die("error :$!");
open($FH_csv, "<:utf8", $file_csv) or die("error :$!");

# PDBo:atom_site.label_atom_id rdf:label "Atom No" .
my $NL_atom_no = new RDF::Trine::Node::Literal("Atom No", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_atom_id,$NO_label,$NL_atom_no));
# PDBo:atom_site.label_atom_id rdf:label "Atom Type" .
my $NL_atom_type = new RDF::Trine::Node::Literal("Atom Type", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_type_symbol,$NO_label,$NL_atom_type));
# PDBo:atom_site.label_comp_id rdf:label "Residue" .
my $NL_residue = new RDF::Trine::Node::Literal("Residue", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_comp_id,$NO_label,$NL_residue));
# PDBo:atom_site.label_seq_id rdf:label "Residue No" .
my $NL_residue_no = new RDF::Trine::Node::Literal("Residue No", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_seq_id,$NO_label,$NL_residue_no));
# PDBo:atom_site.label_asym_id rdf:label "Chain No" .
my $NL_chain_no = new RDF::Trine::Node::Literal("Chain No", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_asym_id,$NO_label,$NL_chain_no));
# PDBo:atom_site.label_atom_id rdf:label "Het Atom No" .
my $NL_het_atom_no = new RDF::Trine::Node::Literal("Het Atom No", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_atom_id,$NO_label,$NL_het_atom_no));
# PDBo:chem_comp_atom.type_symbol rdf:label "Het Atom Name" .
my $NL_het_atom_name = new RDF::Trine::Node::Literal("Het Atom Name", "en");
$model->add_statement(new RDF::Trine::Statement($NO_chem_comp_atom_type_symbol,$NO_label,$NL_het_atom_name));
# PDBo:atom_site.label_seq_id rdf:label "Het Chain No" .
my $NL_het_chain_no = new RDF::Trine::Node::Literal("Het Chain No", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_label_seq_id,$NO_label,$NL_het_chain_no));
# PDBo:chem_comp.name rdf:label "Het Molecule" .
my $NL_het_molecule = new RDF::Trine::Node::Literal("Het Molecule", "en");
$model->add_statement(new RDF::Trine::Statement($NO_chem_comp_name,$NO_label,$NL_het_molecule));
# PDBo:atom_site.Cartn_x rdf:label "Atom X" .
my $NL_atom_x = new RDF::Trine::Node::Literal("Atom X", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_Cartn_x,$NO_label,$NL_atom_x));
# PDBo:atom_site.Cartn_y rdf:label "Atom Y" .
my $NL_atom_y = new RDF::Trine::Node::Literal("Atom Y", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_Cartn_y,$NO_label,$NL_atom_y));
# PDBo:atom_site.Cartn_z rdf:label "Atom Z" .
my $NL_atom_z = new RDF::Trine::Node::Literal("Atom Z", "en");
$model->add_statement(new RDF::Trine::Statement($NO_atom_site_Cartn_z,$NO_label,$NL_atom_z));
# PDBo:chem_comp_atom.model_Cartn_x rdf:label "Het Atom X" .
my $NL_het_atom_x = new RDF::Trine::Node::Literal("Het Atom X", "en");
$model->add_statement(new RDF::Trine::Statement($NO_chem_comp_atom_model_Cartn_x,$NO_label,$NL_het_atom_x));
# PDBo:chem_comp_atom.model_Cartn_y rdf:label "Het Atom Y" .
my $NL_het_atom_y = new RDF::Trine::Node::Literal("Het Atom Y", "en");
$model->add_statement(new RDF::Trine::Statement($NO_chem_comp_atom_model_Cartn_y,$NO_label,$NL_het_atom_y));
# PDBo:chem_comp_atom.model_Cartn_z rdf:label "Het Atom Z" .
my $NL_het_atom_z = new RDF::Trine::Node::Literal("Het Atom Z", "en");
$model->add_statement(new RDF::Trine::Statement($NO_chem_comp_atom_model_Cartn_z,$NO_label,$NL_het_atom_z));
# ddi:distance_to_atom rdf:label "Displacement" .
my $NL_displacement = new RDF::Trine::Node::Literal("Displacement", "en");
$model->add_statement(new RDF::Trine::Statement($NO_distance_to_atom,$NO_label,$NL_displacement));

print $FH_rdf $serializer->serialize_model_to_string($model);
$store = new RDF::Trine::Store::Memory;
$model = new RDF::Trine::Model($store);

my $ref_atom_siteCategory;
my $ref_chem_comp_atomCategory;

# 
while(<$FH_csv>){
    $_ =~ s/[\r\n]*$//;
    my($pdbid,
       $atom_no,
       $atom_type,
       $residue,
       $residue_no,
       $chain_no,
       $het_atom_no,
       $het_atom_name,
       $het_chain_no,
       $het_molecule,
       $atom_x,
       $atom_y,
       $atom_z,
       $het_atom_x,
       $het_atom_y,
       $het_atom_z,
       $displacement)
      = split(/,/, $_);
    my $N_PDBID = new RDF::Trine::Node::Resource("http://pdbj.org/rdf/" . $pdbid);
    my $bsid = join("_", $pdbid, $atom_no, $het_atom_no, "0");
    my $N_BSID = new RDF::Trine::Node::Resource("http://www.bi.a.u-tokyo.ac.jp/rdf/" . $bsid);

    # _:BlankA rdf:type PDBo:atom_site
    my $BL_atom_site = new RDF::Trine::Node::Blank("AtomSite".$pdbid.$atom_no.$het_atom_no."0");
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_type,$NC_atom_site));
    # _:BlankC rdf:type PDBo:chem_comp_atom
    my $BL_chem_comp_atom = new RDF::Trine::Node::Blank("ChemCompAtom".$pdbid.$atom_no.$het_atom_no."0");
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_type,$NC_chem_comp_atom));
    # _:BlankP rdf:type PDBo:atom_siteCategory .
    # _:BlankP rdfs:label "" .
    my $BL_atom_site_category = new RDF::Trine::Node::Blank("AtomSiteCategory".$pdbid."0");
    if(!exists $ref_atom_siteCategory->{"AtomSiteCategory".$pdbid."0"}){
        my $N1 = new RDF::Trine::Node::Literal($pdbid);
        $model->add_statement(new RDF::Trine::Statement($BL_atom_site_category,$NO_type,$NC_atom_siteCategory));
        $model->add_statement(new RDF::Trine::Statement($BL_atom_site_category,$NO_label,$N1));
    }
    $ref_atom_siteCategory->{"AtomSiteCategory".$pdbid."0"} = 1;;
    # _:BlankL rdf:type PDBo:chem_comp_atomCategory .
    # _:BlankL rdfs:label "" .
    my $het_molecule_conv = $het_molecule;
    $het_molecule_conv =~ s/[^a-zA-Z0-9]//g;
    my $BL_chem_comp_atom_category = new RDF::Trine::Node::Blank("ChemCompAtomCategory".$het_molecule_conv."0");
    if(!exists $ref_chem_comp_atomCategory->{"ChemCompAtomCategory".$het_molecule_conv."0"}){
        my $N19 = new RDF::Trine::Node::Literal($het_molecule);
        $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom_category,$NO_type,$NC_chem_comp_atomCategory));
        $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom_category,$NO_label,$N19));
    }
    $ref_chem_comp_atomCategory->{"ChemCompAtomCategory".$het_molecule_conv."0"} = 1;
    # _:BlankP PDBo:has_atom_site _:BlankA .
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site_category,$NO_has_atom_site,$BL_atom_site));
    # _:BlankL PDBo:has_chem_comp_atom _:BlankC .
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom_category,$NO_has_chem_comp_atom,$BL_chem_comp_atom));
    # <BSID> rdf:type bilab:BSID .
    $model->add_statement(new RDF::Trine::Statement($N_BSID,$NO_type,$NC_BSID));
    # <BSID> rdfs:label "" .
    my $N2 = new RDF::Trine::Node::Literal($bsid);
    $model->add_statement(new RDF::Trine::Statement($N_BSID,$NO_label,$N2));
    # <BSID> ddi:distance_to_atom "" .
    my $N18 = new RDF::Trine::Node::Literal($displacement, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($N_BSID,$NO_distance_to_atom,$N18));
    # <BSID> bilab:has_interact_atom_site _:BlankA .
    $model->add_statement(new RDF::Trine::Statement($N_BSID,$NO_has_interact_atom_site,$BL_atom_site));
    # <BSID> bilab:has_interact_chem_comp_atom _:BlankC .
    $model->add_statement(new RDF::Trine::Statement($N_BSID,$NO_has_interact_chem_comp_atom,$BL_chem_comp_atom));
    # _:BlankA PDBo:atom_site.label_atom_id "" .
    my $N3 = new RDF::Trine::Node::Literal($atom_no);
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_label_atom_id,$N3));
    # _:BlankA PDBo:atom_site.type_symbol "" .
    my $N4 = new RDF::Trine::Node::Literal($atom_type);
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_type_symbol,$N4));
    # _:BlankA PDBo:atom_site.label_comp_id "" .
    my $N5 = new RDF::Trine::Node::Literal($residue);
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_label_comp_id,$N5));
    # _:BlankA PDBo:atom_site.label_seq_id "" .
    my $N6 = new RDF::Trine::Node::Literal($residue_no);
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_label_seq_id,$N6));
    # _:BlankA PDBo:atom_site.label_asym_id "" .
    my $N7 = new RDF::Trine::Node::Literal($chain_no);
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_label_asym_id,$N7));
    # _:BlankA PDBo:atom_site.Cartn_x "" .
    my $N8 = new RDF::Trine::Node::Literal($atom_x, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_Cartn_x,$N8));
    # _:BlankA PDBo:atom_site.Cartn_y "" .
    my $N9 = new RDF::Trine::Node::Literal($atom_y, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_Cartn_y,$N9));
    # _:BlankA PDBo:atom_site.Cartn_z "" .
    my $N10 = new RDF::Trine::Node::Literal($atom_z, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_atom_site,$NO_atom_site_Cartn_z,$N10));
    # _:BlankC PDBo:atom_site.label_atom_id "" .
    my $N11 = new RDF::Trine::Node::Literal($het_atom_no);
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_atom_site_label_atom_id,$N11));
    # _:BlankC PDBo:chem_comp_atom.type_symbol "" .
    my $N12 = new RDF::Trine::Node::Literal($het_atom_name);
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_chem_comp_atom_type_symbol,$N12));
    # _:BlankC PDBo:atom_site.label_seq_id "" .
    my $N13 = new RDF::Trine::Node::Literal($het_chain_no);
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_atom_site_label_seq_id,$N13));
    # _:BlankC PDBo:chem_comp.name "" .
    my $N14 = new RDF::Trine::Node::Literal($het_molecule);
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_chem_comp_name,$N14));
    # _:BlankC PDBo:chem_comp_atom.model_Cartn_x "" .
    my $N15 = new RDF::Trine::Node::Literal($het_atom_x, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_chem_comp_atom_model_Cartn_x,$N15));
    # _:BlankC PDBo:chem_comp_atom.model_Cartn_y "" .
    my $N16 = new RDF::Trine::Node::Literal($het_atom_y, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_chem_comp_atom_model_Cartn_y,$N16));
    # _:BlankC PDBo:chem_comp_atom.model_Cartn_z "" .
    my $N17 = new RDF::Trine::Node::Literal($het_atom_z, undef, "http://www.w3.org/2001/XMLSchema#float");
    $model->add_statement(new RDF::Trine::Statement($BL_chem_comp_atom,$NO_chem_comp_atom_model_Cartn_z,$N17));

    print $FH_rdf $serializer->serialize_model_to_string($model);
    $store = new RDF::Trine::Store::Memory;
    $model = new RDF::Trine::Model($store);
}
close($FH_csv);
close( $FH_rdf );

