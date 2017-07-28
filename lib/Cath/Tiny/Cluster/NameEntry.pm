package Cath::Tiny::Cluster::NameEntry;

use Moo;
use Types::Standard -types;

has id           => ( is => 'ro', isa => Str, required => 1 );
has member       => ( is => 'ro', isa => Object, required => 1 );
has terms        => ( is => 'ro', isa => ArrayRef, default => sub { [] } );
has scored_terms => ( is => 'ro', isa => HashRef, default => sub { {} } );
has weighting    => ( is => 'rw', isa => Num, default => sub { 0 } );
has score        => ( is => 'rw', isa => Num, default => sub { 0 } );
has raw_score    => ( is => 'rw', isa => Num, default => sub { 0 } );

1;
