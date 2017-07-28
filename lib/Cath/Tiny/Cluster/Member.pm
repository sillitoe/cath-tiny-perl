package Cath::Tiny::Cluster::Member;

use Moo;
use Types::Standard -types;

with 'Cath::Tiny::Packable';

has acc       => ( is => 'ro', isa => Str ),
has id        => ( is => 'ro', isa => Str ),
has source    => ( is => 'ro', isa => Str ),
has swissprot => ( is => 'ro', isa => Bool, default => sub { 0 } ),
has organism  => ( is => 'ro', isa => Str ),
has name      => ( is => 'ro', isa => Str, default => sub { 'unknown' } ),
has alt_names => ( is => 'ro', isa => ArrayRef, default => sub { [] } );

1;
