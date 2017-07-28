package Cath::Tiny::Segment;

use Moo;
use Carp qw/ confess /;
use Types::Standard -types;
use Cath::Tiny::Types qw/ Residue /;
use Cath::Tiny::Residue;

has 'pdb_res_label' => ( is => 'ro', isa => Str, predicate => 'has_pdb_res_label' );
has 'pdbe_num'      => ( is => 'ro', isa => Int, predicate => 'has_pdbe_num' );
has 'uniprot_num'   => ( is => 'ro', isa => Int, predicate => 'has_uniprot_num' );
has 'seqres_num'    => ( is => 'ro', isa => Int, predicate => 'has_seqres_num' );
has 'combs_num'     => ( is => 'ro', isa => Int, predicate => 'has_combs_num' );

my %coord_type_to_res_attr = (
  PDB => 'pdb_res_label',
  PDBE => 'pdbe_num',
  UNIPROT => 'uniprot_num',
  SEQRES => 'seqres_num',
  COMBS => 'combs_num',
);

has default_coord => (
  is => 'ro', isa => Enum[keys %coord_type_to_res_attr], default => 'PDB'
);

has start_res => (
  is => 'ro',
  isa => Residue,
  required => 1,
  coerce => 1,
);

has stop_res => (
  is => 'ro',
  isa => Residue,
  required => 1,
  coerce => 1,
);

sub new_from_pdb_string {
  my $class = shift if $_[0] eq __PACKAGE__;
  my $seg_str = shift;
  $seg_str =~ /^ (-?[0-9]+[A-Z]?) - (-?[0-9]+[A-Z]?) $/xms
    or confess "! Error: failed to parse segment string '$seg_str'";
  my ($start, $stop) = ($1, $2);
  __PACKAGE__->new(
    start_res => Cath::Tiny::Residue->new( pdb_res_label => $start ),
    stop_res => Cath::Tiny::Residue->new( pdb_res_label => $stop ),
  );
}

sub to_string {
  my $self = shift;
  return join( "-", $self->start_res, $self->stop_res );
}

1;
