use Test::More;

use strict;
use warnings;

use Cath::Tiny::Test;

use_ok( 'Cath::Tiny::Version' );

my @ver_data = (
  [ '4.1'    => 'v4.1.0' ],
  [ 'v4_1_0' => 'v4.1.0' ],
  [ 'v4_1'   => 'v4.1.0' ],
);

for ( @ver_data ) {
  my ($from, $to) = @$_;
  my $v = Cath::Tiny::Version->new_from_string( $from );
  is( $v->stringify, $to );
}

done_testing;
