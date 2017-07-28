package Cath::Tiny::Version;

=head1 NAME

Cath::Tiny::Version - deal with versions

=head1 SYNOPSIS

  $v = Cath::Tiny::Version->new(
    major => 4,
    minor => 1,
    revision => 123
  );

  $v = Cath::Tiny::Version->new_from_string( '4.1.123' );

  # v4.1.123
  $v->stringify;

  # release 4.1 (revision 123)
  $v->stringify( 'release %d.%d (revision %d)' );

  # v4.1.0
  $v = Cath::Tiny::Version->new_from_string( '4-1' );

=head1 METHODS

=cut

use Moo;
use Types::Standard -types;

has major    => ( is => 'ro', isa => Int, required => 1 );
has minor    => ( is => 'ro', isa => Int, default => 0 );
has revision => ( is => 'ro', isa => Int, default => 0 );

has format => ( is => 'rw', isa => Str, default => 'v%d.%d.%d' );

sub stringify {
    my $self = shift;
    my $format = shift || $self->format;
    return sprintf( $format, $self->major, $self->minor, $self->revision );
}

sub new_from_string {
  my $class = shift if $_[0] eq __PACKAGE__;
  my $str = shift;
  $str =~ s/^[vV]//;
  my ($major, $minor, $rev) = split( /[.\-_]/, $str );
  __PACKAGE__->new(
    major => $major,
    $minor ? ( minor => $minor ) : (),
    $rev   ? ( revision => $rev ) : (),
  );
}

1;
