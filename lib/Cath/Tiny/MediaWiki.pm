package Cath::Tiny::MediaWiki;

use Moo;
use Types::Standard -types;
use MediaWiki::API;

has 'api_url' => ( isa => Str, is => 'ro', default => 'https://en.wikipedia.org/w/api.php' );
has 'mw'      => ( isa => Object, is => 'ro', lazy => 1, builder => '_build_mw',
    handles => [qw/ list login logout edit get_page upload download /],
  );

sub _build_mw {
  my $self = shift;
  my $mw = MediaWiki::API->new( { api_url => $self->api_url } );
  return $mw;
}

1;
