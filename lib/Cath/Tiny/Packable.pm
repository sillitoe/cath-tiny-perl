package Cath::Tiny::Packable;

=head1 NAME

Cath::Tiny::Package - role to pack objects to/from data structures

=head1 SYNOPSIS

  package My::Object;
  use Moo;
  with 'Cath::Tiny::Packable';
  has 'foo' => ( is => 'ro' );

  my $obj = My::Object->new( foo => 'bar' );

  # create flat data structure from object
  #   { __CLASS__ => 'My::Object', foo => 'bar' }
  my $data = $obj->pack();

  # recreate object from data structure
  my $obj_copy = My::Object->unpack( $data );

=head1 DESCRIPTION

This is here because L<Moo> does not have an equivalent to L<MooseX::Storage>.

Since L<Moo> is not able to provide much object introspection, the following
conventions are used when packing an object into data strucure:

=over

=item attributes starting with '_' are ignored

=item lazy attributes that have not yet been built are ignored

=back

=cut

use Moo::Role;
use strict;
use warnings;
use Carp qw/ confess /;
use Scalar::Util qw/ blessed /;
use Data::Dumper;
use JSON::MaybeXS qw/ decode_json encode_json /;
use namespace::autoclean;

=head1 PROVIDES METHODS

=head2 pack()

Returns flattened data structure from object

=cut

sub pack {
  my $self = shift;
  my %data = map {
    my $key = $_;
    my $val = $self->{$key};
    if ( ref $val ) {
      if ( ref $val eq 'ARRAY' ) {
        $val = [ map { _pack_object( $_ ) } @$val ];
      }
      elsif ( ref $val eq 'HASH' ) {
        $val = _pack_object( $val );
      }
      elsif ( blessed $val && $val->can('pack') ) {
        $val = $val->pack;
      }
    }
    ($key => $val);
  } grep { ! /^_/ } keys %$self;
  $data{__CLASS__} = blessed $self;
  return \%data;
}

sub _pack_object {
  my $obj = shift;
  if ( blessed $obj ) {
    if ( $obj->can('pack') ) {
      return $obj->pack;
    }
    else {
      confess sprintf "cannot convert to hash: object %s has no pack() method", blessed $obj;
    }
  }
  else {
    return $obj;
  }
}

=head2 unpack( $data )

Class method that returns object from a previously created data structure

  $obj = My::Object->unpack( $data );

=cut

sub unpack {
  my $class = shift;
  my $data = scalar @_ == 1 ? $_[0] : { @_ };

  my %unpacked_data = map {
    my $key = $_;
    my $val = $data->{$key};
    if ( ref $val eq 'HASH' ) {
      $val = _unpack_object( $val );
    }
    elsif ( ref $val eq 'ARRAY' ) {
      $val = [ map { ref $_ eq 'HASH' ? _unpack_object($_) : $_ } @$val ];
    }
    ($key => $val);
  } keys %$data;

  return $class->new( %unpacked_data );
}

sub _unpack_object {
  my $data = shift;
  if (exists $data->{__CLASS__}) {
    my $cl = $data->{__CLASS__};
    my %attr = %$data;
    delete $attr{__CLASS__};
    # require $cl;
    return $cl->unpack( %attr );
  }
  else {
    return $data;
  }
}

sub freeze {
  my $self = shift;
  return encode_json( $self->pack );
}

sub thaw {
  my $class = shift;
  my $data = scalar @_ == 1 ? $_[0] : { @_ };
  return $class->unpack( decode_json( $data ) );
}

1;
