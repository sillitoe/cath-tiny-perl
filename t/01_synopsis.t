use Test::More;

use strict;
use warnings;
use List::Util qw/ first /;
use FindBin;

use lib "$FindBin::Bin/../extlib/lib/perl5";

use HTTP::Tiny;
use JSON::MaybeXS;
use Path::Tiny;

use Cath::Tiny::App::Cmd::Cluster;
use Cath::Tiny::Cluster;

my $cath_version = 'v4_1_0';
my $sfam_id = '3.40.50.620';
my $ff_num = 88403;
my $funfam_id = join( '/', $sfam_id, 'FF', $ff_num );

my $app = Cath::Tiny::App::Cmd::Cluster->new( funfam => $funfam_id );

my $cluster = $app->cluster;

my $cluster_data = $cluster->pack;

my $cluster_data_file = path( "$FindBin::Bin/data/$funfam_id.json" );
$cluster_data_file->spew( encode_json( $cluster_data ) );

my $cluster_new = Cath::Tiny::Cluster->unpack( $cluster_data );

is_deeply( $cluster_data, $cluster_new->pack, 'cluster packs/unpacks okay' );

for my $mem ( $cluster->list_all_members ) {
  printf( "%-20s %-20s %-8s %-4s %s\n", $mem->acc, $mem->id, $mem->source, $mem->swissprot ? 'SP' : '-', $mem->name )
}

done_testing;
