use Test::More;

use strict;
use warnings;

use Cath::Tiny::Test;

use_ok( 'Cath::Tiny::Types', '-all' );

ok( is_CathDomainIDStr( '1cukA01' ), 'type check imported okay (and works)' );

my @segs_data = (
  [ '-5', '20A' ],
  [ '40', '80' ],
);

use_ok( 'Cath::Tiny::Segment' );
use_ok( 'Cath::Tiny::Residue' );

my @segs = map {
    my ($start, $stop) = @$_;
    Cath::Tiny::Segment->new(
      start_res => Cath::Tiny::Residue->new( pdb_res_label => $start ),
      stop_res => Cath::Tiny::Residue->new( pdb_res_label => $stop ) ,
    );
  } @segs_data;

is_deeply( to_ArrayOfSegments( '-5-20A,40-80' ), \@segs, 'type coercion imported (and works)' );

done_testing;
