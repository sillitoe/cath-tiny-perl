use Test::More;

use strict;
use warnings;

use Cath::Tiny::Test;

use_ok( 'Cath::Tiny::Domain' );

my @ids = (
  [ '1cukA01', '4.1', 'CATH' ],
);

for my $id_data ( @ids ) {
  my ($id, $ver, $db) = @$id_data;
  my $dom = Cath::Tiny::Domain->new( id => $id, version => $ver );
  isa_ok( $dom, 'Cath::Tiny::Domain' );
  is( $dom->stringify, $id, 'stringify to id looks okay' );
  is( $dom->db_source, $db, 'db_source looks okay' );
}

done_testing();
