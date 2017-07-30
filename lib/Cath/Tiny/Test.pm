package Cath::Tiny::Test;

use FindBin;
use File::Spec;
use Config;

BEGIN {
  my @dirs = File::Spec->splitdir( "$FindBin::Bin" );
  my @root_parts;
  for my $d ( @dirs ) {
    last if $d eq 't';
    push @root_parts, $d;
  }
  my $root_dir = File::Spec->catdir( @root_parts );

  my $archname = $Config{archname};

  warn "ROOT_DIR: $root_dir";
  warn "INC (BEFORE): " . join ( ',', @INC );
  unshift @INC,
    File::Spec->catdir( @root_parts, 'lib' ),
    File::Spec->catdir( @root_parts, 'extlib', 'lib', 'perl5' ),
    File::Spec->catdir( @root_parts, 'extlib', 'lib', 'perl5', $archname )
    ;
  warn "INC (AFTER): " . join ( ',', @INC );
}
# use lib "$FindBin::Bin/../lib";
# use lib "$FindBin::Bin/../extlib/lib/perl5";

1;
