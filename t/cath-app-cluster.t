use Test::More;

use strict;
use warnings;
use List::Util qw/ first /;
use FindBin;
use Data::Dumper;

use lib "$FindBin::Bin/../extlib/lib/perl5";

use HTTP::Tiny;
use JSON::MaybeXS;
use Path::Tiny;

use Cath::Tiny::App::Cmd::Cluster;
use Cath::Tiny::Cluster;

my $BOOTSTRAP = $ENV{CATH_TEST_BOOTSTRAP} // 0;

my $cath_version = 'v4_1_0';
my $sfam_id = '3.40.50.620';
my $ff_num = 88403;
my $funfam_id = join( '/', $sfam_id, 'FF', $ff_num );
(my $funfam_id_file = $funfam_id ) =~ s{/}{-}gm;

my $cluster_data_file = path( "$FindBin::Bin/data/$funfam_id_file.json" );

if ( $BOOTSTRAP ) {
  diag( "Bootstrapping test data ... (creating: $cluster_data_file)" );
  my $app = Cath::Tiny::App::Cmd::Cluster->new( funfam => $funfam_id, nocache => 1 );
  $cluster_data_file->spew( $app->cluster->freeze );
}

my $cluster_data = decode_json( $cluster_data_file->slurp );

my $cluster = Cath::Tiny::Cluster->unpack( $cluster_data );

is_deeply( $cluster_data, $cluster->pack, 'cluster packs/unpacks okay' );

# for my $mem ( $cluster->list_all_members ) {
#   diag sprintf( "%-20s %-20s %-8s %-4s %s\n", $mem->acc, $mem->id, $mem->source, $mem->swissprot ? 'SP' : '-', $mem->name );
# }

done_testing;
