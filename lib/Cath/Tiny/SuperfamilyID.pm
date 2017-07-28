package Cath::Tiny::SuperfamilyID;

use Moo;

use Cath::Tiny::Types qw/ ArrayOfInts /;

has id_parts => ( is => 'ro', isa => ArrayOfInts )

1;
