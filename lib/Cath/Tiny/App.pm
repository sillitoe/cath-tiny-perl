package Cath::Tiny::App;

use Moo;
use MooX::Cmd;
use MooX::Options;
use Data::Dumper;

sub execute {
  my ($self,$args,$chain) = @_;
  #print Dumper( $self );

  printf("%s.execute(\$self,[%s],[%s])\n",
    ref($self),
    $args  ? join(", ", @$args) : 'undef',
    $chain ? join(", ", map { ref } @$chain) : 'undef',
  );
}

1;
