package Cath::Tiny::Residue;

use Moo;
use Types::Standard -types;

has 'pdb_res_label' => ( is => 'ro', isa => Str, predicate => 'has_pdb_res_label' );
has 'pdbe_num'      => ( is => 'ro', isa => Int, predicate => 'has_pdbe_num' );
has 'uniprot_num'   => ( is => 'ro', isa => Int, predicate => 'has_uniprot_num' );
has 'seqres_num'    => ( is => 'ro', isa => Int, predicate => 'has_seqres_num' );
has 'combs_num'     => ( is => 'ro', isa => Int, predicate => 'has_combs_num' );

1;
