package Cath::Tiny::Domain;

use Moo;
use Cath::Tiny::Types qw/ AnyDomainIDStr Version /;
use Types::Standard -types;
use Cath::Tiny::Utils;

around BUILDARGS => sub {
  my ( $orig, $class, %args ) = @_;
  return $class->$orig( %args );
};

has id         => ( is => 'ro', isa => AnyDomainIDStr );
has db_version => ( is => 'ro', isa => Version );
has db_source  => ( is => 'ro', isa => Str, lazy => 1, builder => 'guess_db_source' );

sub guess_db_source {
    my $self = shift;
    return Cath::Tiny::Utils::guess_db_source_from_domain_id( $self->id );
}

sub stringify { (shift)->id }

1;
