package Cath::Tiny::Cluster;

# core
use List::Util qw/ first /;
use Scalar::Util qw/ blessed /;
use Data::Dumper;
use Carp qw/ croak confess /;

# cpan deps
use Moo;
use JSON::MaybeXS;
use HTTP::Tiny;
use Types::Standard -types;
use Try::Tiny;

# local
use Cath::Tiny::Cluster::Member;

# tidy up namespace
use namespace::autoclean;

our $VERSION = '0.01';

# attr
has name             => ( is => 'rw', isa => Str );
has members          => ( is => 'rw', isa => ArrayRef, default => sub { [] } );

# helpers
has json  => ( is => 'ro', isa => Object, default => sub { JSON::MaybeXS->new() } );
has http  => ( is => 'ro', isa => Object, default => sub { HTTP::Tiny->new() } );

sub list_all_members {
  my $self = shift;
  return @{ $self->members };
}

=head2 $obj->pack

Return a data structure for this object

=cut

sub pack {
  my $self = shift;
  my %data = (
    name    => $self->name,
    members => [ map { $_->pack } $self->list_all_members ], # Moo objects are essentially hashes
  );
  return \%data;
}

=head2 Cath::Tiny::Cluster->unpack( \%data )

Create a new object from a data structure

=cut

sub unpack {
  my $class = shift;
  my $data = shift;

  my @members = map { Cath::Tiny::Cluster::Member->new( %$_ ) } @{ $data->{members} };
  $data->{members} = \@members;

  # HACK: just to get this working on some cached data (while I'm sans wifi)
  delete $data->{name} if ! defined $data->{name};

  return __PACKAGE__->new( %$data );
}

sub new_from_funfam {
  my $class = shift;
  my $funfam_uri = shift;

  my $cluster = __PACKAGE__->new();

  my $stockholm_content = $cluster->get_alignment_from_uri( $funfam_uri );

  $cluster->populate_from_stockholm( $stockholm_content );

  return $cluster;
}

sub _members_from_accessions {
  my $self = shift;
  my $accessions = shift;
  my @members;
  ACC: for my $acc_data ( @$accessions ) {
    my $member;
    try {
      if ( $acc_data->{source} eq 'CATH' ) {
        $member = $self->get_member_from_cath_domain( $acc_data->{acc} );
      }
      elsif ( $acc_data->{source} eq 'GENE3D' ) {
        $member = $self->get_member_from_uniprot_acc( $acc_data->{acc} );
      }
      else {
        die "failed to understand source: " . $acc_data->{source};
      }
    } catch {
      my $id = $acc_data->{id};
      warn "! Warning: caught error $_ (skipping $id)\n";
    };
    push @members, $member
      if $member;
  }
  return \@members;
}

sub get_member_from_uniprot_acc {
  my $self = shift;
  my $uniprot_acc = shift;
  my $http = $self->http;
  my $json = $self->json;
  my $uri = 'https://www.ebi.ac.uk/proteins/api/proteins/' . $uniprot_acc;

  my $data = $self->get_data_from_uri( $uri );

  my $org = map { $_->{value} } first { $_->{type} && $_->{type} eq 'scientific' }
    @{ $data->{organism}->{names} };

  my $name      = try { $data->{protein}->{recommendedName}->{fullName}->{value} || 'unknown' } catch { 'unknown' };
  my $swissprot = try { $data->{info}->{type} eq 'Swiss-Prot' } catch { 0 };
  my @alt_names = map { $_->{fullName}->{value} } @{ $data->{protein}->{alternativeName} };

  my $member = try { Cath::Tiny::Cluster::Member->new(
    acc => $data->{accession},
    id => $data->{id},
    source => 'UNIPROT',
    swissprot => $swissprot,
    organism => $org,
    ( $name      ? (name      => $name)       : () ),
    ( @alt_names ? (alt_names => \@alt_names) : () ),
  ) }
  catch {
    local $Data::Dumper::Maxdepth = 2;
    croak "! Error: failed to create ClusterMember\nCONTENT: " . Dumper( $data ) . "\nERROR: $_";
  };

  return $member;
}

sub get_member_from_cath_domain {
  my $self = shift;
  my $domain_id = shift
    or confess "! Error: expected domain id";
  my $pdb_code = substr( $domain_id, 0, 4 );

  my $uri = 'http://www.ebi.ac.uk/pdbe/api/pdb/entry/summary/' . $pdb_code;

  my $data = $self->get_data_from_uri( $uri );

  $data = $data->{$pdb_code}->[0];

  my $member = Cath::Tiny::Cluster::Member->new(
    acc => $pdb_code,
    id => $domain_id,
    source => 'PDB',
    name => $data->{title},
  );
  return $member;
}

sub get_alignment_from_uri {
  my $self = shift;
  my $uri = shift;
  my $http = HTTP::Tiny->new();
  my $response = $http->get( $uri );
  croak "failed to get funfam alignment from uri: $uri"
    unless $response->{success};
  return $response->{content};
}

sub populate_from_stockholm {
  my $self = shift;
  my $stockholm_content = shift;
  my @accessions;
  my @lines = split( /\n/, $stockholm_content );

  my $name;
  for my $line ( @lines ) {
    if ( $line =~ m{ ^ \#=GF \s+ DE \s+ (.*?) $} ) {
      $name = $1;
    }
    if ( $line =~ m{ ^ \#=GS \s+ ([0-9a-zA-Z]+) / ([0-9_\-]+) \s+ DR \s+ (CATH|GENE3D); }xms ) {
      my ( $acc, $segs, $src ) = ($1, $2, $3);
      my $accession = {
        source => $src,
        id => join( '/', $acc, $segs ),
        acc => $acc,
      };
      push @accessions, $accession;
    }
  }

  my $members = $self->_members_from_accessions( \@accessions );

  $self->name( $name ) if $name;
  $self->members( $members );
}

sub get_data_from_uri {
  my $self = shift;
  my $uri = shift;

  my $http = $self->http;
  my $json = $self->json;

  my $response = $http->get( $uri, {
      headers => { 'Accept' => 'application/json' }
    });

  croak "http error when getting uri '$uri' : " . $response->{status}
    unless $response->{success};

  croak "failed to get any content from URI '$uri'"
    unless $response->{content};

  my $data = try { $json->decode( $response->{content} ) }
  catch {
    croak "failed to parse JSON from uri: $uri\nCONTENT: " . $response->{content};
  };

  return $data;
}

1;
