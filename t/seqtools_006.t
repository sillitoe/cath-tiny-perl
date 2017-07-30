use Test::More tests => 3;

use strict;
use warnings;
use Cath::Tiny::Test;
use File::Temp qw/ tempdir /;

use_ok( 'Cath::Tiny::App::Cmd::Seqscan' );

my $tmp_dir = tempdir( CLEANUP => 1 );
(my $fasta_file = $0) =~ s{\.t$}{.fa};

my $app = Cath::Tiny::App::Cmd::Seqscan->new(
  in  => $fasta_file,
  out => $tmp_dir,
);

isa_ok( $app, 'Cath::Tiny::App::Cmd::Seqscan' );

ok( $app->run, 'app runs okay' );
