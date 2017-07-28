package Cath::Tiny::Cluster::NamingScheme::BaseRole;

use Moo::Role;
use Text::ParseWords;
use Types::Standard -types;
use Cath::Tiny::Cluster::NameEntry;

requires qw/ score_entries /;

my @default_ignore_terms = qw(
  putative
  uncharacterized
  protein
  uncharacterized-protein
  and of the
  unknown
);

has new_name     => ( is => 'rw', isa => Str );
has cluster      => ( is => 'ro', isa => Object );
has ignore_terms => ( is => 'ro', isa => ArrayRef[Str], default => sub { \@default_ignore_terms } );

sub list_all_ignore_terms { @{ (shift)->ignore_terms } }

sub new_entry {
  my $self = shift;
  return Cath::Tiny::Cluster::NameEntry->new( @_ );
}

sub _normalise_terms {
  my $str = shift;
  my @terms = map { lc($_) } quotewords( '[,\s]+', 0, $str );
  s/[.,()]//mg for @terms;
  return @terms;
}

1;
