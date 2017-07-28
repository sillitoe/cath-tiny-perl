package Cath::Tiny::App;

use Moo;
use MooX::Cmd;

sub execute {
    my ($self, $args_ref, $chain_ref) = @_;
    my @extra_argv = @{$args_ref};
    my @chain = @{$chain_ref};
}

1;
