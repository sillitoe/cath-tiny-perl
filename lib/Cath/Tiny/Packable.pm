package Cath::Tiny::Packable;

use Moo::Role;
use Scalar::Util qw/ blessed /;

sub pack {
  my $self = shift;
  my %data = map {
    my $key = $_;
    my $val = $self->{$_};
    if ( ref $val ) {
      elsif ( ref $val eq 'ARRAY' ) {
        $val = [ map {
          my $v = $_;
          blessed $v ? ( $v->can('pack') ? $v->pack : \%$v ) : $v;
        } @$val ];
      }
      elsif ( ref $val eq 'HASHREF' ) {
        $val = { map {
          my $k = $_;
          my $v = $val->{$k};
          ( $k => blessed $v ? ( $v->can('pack') ? $v->pack : \%$v ) : $v );
        } keys %$val };
      }
      elsif ( blessed $val && $val->can('pack') ) {
        $val = $val->pack;
      }
    }
    ($key => $val);
  } keys %$self;
  $data{__CLASS__} = blessed $self;
  return \%data;
}

sub _hash_from_obj {
  my $obj = $_;
  my %data;
  if ( blessed $obj ) {
    if ( $obj->can('pack') ) {
      %data = (
        __CLASS__ => blessed $obj,
        map { ($_ => $obj->{$_}) } keys %$obj,
      );
    }
    else {
      confess sprintf "cannot convert to hash: object %s has no pack() method", blessed $obj;
    }
  }
  else {
    return ;
  }
  return \%data;
}

sub _obj_from_hash {
  my $data = $_;
  if (exists $data->{__CLASS__}) {
    my $cl = delete $data->{__CLASS__};
    # require $cl;
    return $cl->new( %$data );
  }
  else {
    return $data;
  }
}

sub unpack {
  my $class = shift;
  my $data = shift;
  map {
    my $key = $_;
    my $val = $data->{$key};
    if ( ref $val eq 'HASHREF' ) {
    }
    $data->{$key} = $val;
  } keys %$data;
  __PACKAGE__->new( %$_[0] );
}

1;
