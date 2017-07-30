package Cath::Tiny::App::Cmd::Cluster;

# core
use Data::Dumper;
use Digest::MD5 qw/ md5_hex /;
use Storable;

# extlib
use Moo;
use MooX::Cmd;
use MooX::Options;
use CHI;
use Types::Standard -types;
use Path::Tiny;
use Types::Path::Tiny qw/ Dir /;
use Log::Any::Adapter;
use Log::Dispatch;

# lib
use Cath::Tiny::Cluster;
use Cath::Tiny::Cluster::NamingScheme::RepresentativeUniprotDescription;

# roles
with "MooX::Log::Any";

# Send all logs to Log::Dispatch
my $log = Log::Dispatch->new(outputs => [
    #[ 'File',   min_level => 'debug', filename => 'logfile' ],
    [ 'Screen', name => 'Screen', min_level => 'info', newline => 1 ],
  ]);

Log::Any::Adapter->set( 'Dispatch', dispatcher => $log );

option funfam => ( is => 'ro', isa => Str, required => 1, format => 's',
  doc => 'FunFam ID (eg "1.10.8.10/FF/77086" )' );

option cath => ( is => 'ro', isa => Str, format => 's',
  default => sub { 'latest' },
  doc => 'Version of CATH (default: latest)' );

option cache_dir => ( is => 'ro', isa => Dir, coerce => 1, format => 's',
  default => sub { path("~/.cath-tiny-cache") },
  doc => 'Base directory to use for cache (default: /tmp)' );

option verbose => ( is => 'ro', isa => Bool, default => 0, trigger => \&setup_debug_mode,
  doc => 'More verbose logging' );

option nocache => ( is => 'ro', isa => Bool,
  default => 0,
  doc => "do not use cache" );

has cache => ( is => 'ro', isa => Object, lazy => 1, builder => '_build_cache' );

sub _build_cache {
  my $self = shift;
  my $cache = CHI->new( driver => 'File', root_dir => $self->cache_dir->stringify );
  return $cache;
}

has cluster => ( is => 'ro', isa => Object, lazy => 1, builder => 'build_cluster_from_funfam_id' );

has naming_scheme => ( is => 'ro', isa => Object, lazy => 1, builder => 'build_cluster_naming_scheme' );

sub build_cluster_naming_scheme {
  my $self = shift;
  my $cluster = $self->cluster;
  my $name_scheme = Cath::Tiny::Cluster::NamingScheme::RepresentativeUniprotDescription->new(
      cluster => $cluster,
    );
  return $name_scheme;
}

sub execute {
  my ( $self, $args, $chain ) = @_;

  my $funfam_id = $self->funfam;
  my $cluster = $self->cluster;
  my $naming_scheme = $self->naming_scheme;

  for my $mem ( $cluster->list_all_members ) {
    printf( "%-20s %-20s %-8s %-4s %s\n", $mem->acc, $mem->id, $mem->source, $mem->swissprot ? 'SP' : '-', $mem->name )
  }

  my @name_entries = $naming_scheme->score_entries;
}

sub build_cluster_from_funfam_id {
  my $self = shift;

  my $funfam_id    = $self->funfam;
  my $nocache      = $self->nocache;
  my $cache        = $self->cache;
  my $cath_version = $self->cath;

  $self->log->info( "Retrieving cluster (funfam: $funfam_id)" );

  $funfam_id =~ m{^ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) /FF/ (\d+) }mxs
    or croak "! Error: failed to parse funfam id '$funfam_id'";

  my ($sfam_id, $ff_num) = ($1, $2);

  my $funfam_uri = sprintf( "http://cathdb.info/version/%s/superfamily/%s/funfam/%s/files/stockholm",
      $cath_version,
      $sfam_id,
      $ff_num
    );

  my $cache_key = md5_hex( 'Cath::Tiny::Cluster', $Cath::Tiny::Cluster::VERSION, $funfam_uri );
  my $cluster;
  $self->log->debug( "Checking for existing cluster in cache ($cache_key)" );
  if ( my $cluster_data = $cache->get( $cache_key ) ) {
    if ( !$nocache ) {
      $self->log->debug( "  ... found" );
      $cluster = Cath::Tiny::Cluster->unpack( $cluster_data );
    }
    else {
      $self->log->debug( "  ... found (but nocache is set)" );
    }
  }
  else {
    $self->log->debug( "  ... not found" );
  }

  if ( !$cluster ) {
    $self->log->debug( "Building cluster..." );
    $cluster = Cath::Tiny::Cluster->new_from_funfam( $funfam_uri );

    $self->log->debug( "  storing cluster in cache" );
    my $cluster_data = $cluster->pack;

    $cache->set( $cache_key, $cluster_data );
  }

  return $cluster;
}

sub setup_debug_mode {
  my $self = shift;
  $log->remove( 'Screen' );
  $log->add( Log::Dispatch::Screen->new(
    name => 'Screen',
    min_level => 'debug',
    newline => 1,
  ));
}

1;
