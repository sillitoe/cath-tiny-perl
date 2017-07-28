package Cath::Tiny::DomainID;

use Moo;
use Cath::Tiny::Types qw/ PdbCodeStr CathDomainIDStr /;

has pdb_code => ( is => 'ro', isa => CathPdbCodeStr, required => 1 );
has chain_code => ( is => 'ro', isa => Int, required => 1 );
has domain_number => ( is => 'ro', isa => Int, default => '0' );

sub id {
  my $self = shift;
  sprintf "%s%s%02d", $self->pdb_code, $self->chain_code, $self->domain_number;
}

sub stringify { (shift)->id }

1;
