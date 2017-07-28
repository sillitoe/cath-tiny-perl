use Test::More;

use strict;
use warnings;
use Cath::Tiny::Test;

package My::Obj;

use Moo;

with 'Cath::Tiny::Packable';

has 'attr1' => ( is => 'ro', default => sub { 'default1' } );
has 'attr2' => ( is => 'ro' );
has 'attr3' => ( is => 'ro' );
has 'attr4' => ( is => 'ro', lazy => 1, builder => '_build_attr4' );
sub _build_attr4 { 'lazy4' }

no Moo;

package main;

{
  my $obj = My::Obj->new();
  is_deeply( $obj->pack, { attr1 => 'default1' }, 'default works okay' );
}

{
  my $obj = My::Obj->new( attr2 => 'val2', attr3 => 'val3' );
  is_deeply( $obj->pack, { attr1 => 'default1', attr2 => 'val2', attr3 => 'val3' }, 'default/explicit work okay' );
}

{
  my $obj = My::Obj->new( attr1 => 'val1', attr2 => 'val2', attr3 => 'val3' );
  is_deeply( $obj->pack, { attr1 => 'val1', attr2 => 'val2', attr3 => 'val3' }, 'override defaults okay');
}

{
  my $obj = My::Obj->new( attr2 => 'val2' );
  is_deeply( $obj->pack, { attr1 => 'default1', attr2 => 'val2' }, 'lazy not present (before build)');
  is( $obj->attr4, 'lazy4', 'build lazy okay' );
  is_deeply( $obj->pack, { attr1 => 'default1', attr2 => 'val2', attr4 => 'lazy4' }, 'lazy present (after build)' );
}

done_testing;
