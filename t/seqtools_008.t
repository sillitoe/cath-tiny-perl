use Test::More tests => 5;

use strict;
use warnings;

use Cath::Tiny::Test;

use Path::Class;
use Bio::SeqIO;
use File::Temp qw/ tempdir /;

use_ok( 'Cath::Tiny::App::Cmd::Seqscan' );

my $tmp_dir = tempdir( CLEANUP => 0 );

(my $fasta_file = $0) =~ s{\.t$}{.fa};

my $app = Cath::Tiny::App::Cmd::Seqscan->new(
  in  => $fasta_file,
  out => $tmp_dir,
  max_aln => 1,
  no_cache => 1,
);

isa_ok( $app, 'Cath::Tiny::App::Cmd::Seqscan' );

diag( "tmp_dir: $tmp_dir" );

ok( $app->run, 'app runs okay' );

my $aln_file = dir( "$tmp_dir" )->file( "1.10.565.10-FF-338.fasta" );

ok( -e $aln_file, "alignment file `$aln_file` exists" );

my $fh = $aln_file->open;

my $seqio = Bio::SeqIO->new( -file => $aln_file, -format => 'fasta' );

my $seq_length;
my $seq_idx=0;
while( my $seq = $seqio->next_seq ) {
  $seq_length ||= $seq->length;
  if ( $seq->length != $seq_length ) {
    die sprintf( "! Error: length mismatch in sequence [%d] alignment file `$aln_file` (%d vs %d residues)", $seq_idx, $seq_length, $seq->length );
  }
  $seq_idx++;
}

ok( 1, "All alignment lengths the same" );
