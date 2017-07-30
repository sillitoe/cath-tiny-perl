use Test::More;

use strict;
use warnings;
use Cath::Tiny::Test;

package My::Obj1;
use Moo;
with 'Cath::Tiny::Packable';
has 'o1_attr1' => ( is => 'ro' );
has 'o1_attr2' => ( is => 'ro', default => sub { 'default1' } );
no Moo;

package My::Obj2;
use Moo;
use Scalar::Util qw/ blessed /;
with 'Cath::Tiny::Packable';
has 'o2_attr1' => ( is => 'ro' );
has 'o2_attr2' => ( is => 'ro', default => sub { 'default2' } );
has 'o2_attr3' => ( is => 'ro', isa => sub { ref $_[0] eq 'ARRAY' } );
has 'o2_attr4' => ( is => 'ro', isa => sub { ref $_[0] eq 'HASH' } );
has 'o2_attr5' => ( is => 'ro', isa => sub { blessed $_[0] eq 'My::Obj1' } );
has 'o2_attr6' => ( is => 'ro', lazy => 1, builder => '_build_attr6' );
has '_private' => ( is => 'ro' );
sub _build_attr6 { 'lazy6' }
no Moo;

package main;


my %o2_expected = (
  __CLASS__ => 'My::Obj2',
  o2_attr2 => 'default2',
);
{
  my $obj = My::Obj2->new( o2_attr1 => 'attr1' );
  is_deeply( $obj->pack, { %o2_expected, o2_attr1 => 'attr1' },
    'explicit set works okay' );
}

{
  my $obj = My::Obj2->new( o2_attr1 => 'val1', o2_attr2 => 'val2' );
  is_deeply( $obj->pack, { %o2_expected, o2_attr1 => 'val1', o2_attr2 => 'val2' },
    'override defaults okay');
}

{
  my $obj = My::Obj2->new( o2_attr4 => { key => 'value' } );
  is_deeply( $obj->pack, { %o2_expected,
      o2_attr4 => { key => 'value' },
    },
    'HASH works okay' );
}

{
  my $attr5 = My::Obj1->new( o1_attr1 => 'attr1' );
  my $obj = My::Obj2->new( o2_attr5 => $attr5 );
  is_deeply( $obj->pack, { %o2_expected,
    o2_attr5 => { __CLASS__ => 'My::Obj1', o1_attr1 => 'attr1', o1_attr2 => 'default1' },
    },
    'unpack Object works okay' );
}

{
  my $attr3 = [ map { My::Obj1->new( o1_attr1 => $_ ) } qw/ o1_attr1_1 o1_attr1_2 / ];
  my $obj = My::Obj2->new( o2_attr3 => $attr3 );
  is_deeply( $obj->pack, { %o2_expected,
    o2_attr3 => [
      { __CLASS__ => 'My::Obj1', o1_attr1 => 'o1_attr1_1', o1_attr2 => 'default1' },
      { __CLASS__ => 'My::Obj1', o1_attr1 => 'o1_attr1_2', o1_attr2 => 'default1' },
    ]},
    'unpack Array[Object] works okay');
}

{
  my $obj = My::Obj2->new( o2_attr2 => 'val2' );
  is_deeply( $obj->pack, { __CLASS__ => 'My::Obj2', o2_attr2 => 'default2', o2_attr2 => 'val2' },
    'lazy not present (before build)');
  is( $obj->o2_attr6, 'lazy6', 'build lazy okay' );
  is_deeply( $obj->pack, { __CLASS__ => 'My::Obj2', o2_attr2 => 'default2', o2_attr2 => 'val2', o2_attr6 => 'lazy6' },
    'lazy is present (after build)' );
}

{
  my $obj = My::Obj2->new( _private => 'private_value' );
  is_deeply( $obj->pack, { %o2_expected }, 'private attr is not packed' );
}

done_testing;
