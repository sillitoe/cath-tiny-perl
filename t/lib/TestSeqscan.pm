package TestSeqscan;

use FindBin;
use Carp qw/ confess /;
use File::Temp qw/ tempdir /;

use Cath::Tiny::Test;

use Moo;
use Path::Class;
use Bio::SeqIO;

use Cath::Tiny::App::Cmd::Seqscan;

has query_file => (
  is => 'ro',
  lazy => 1,
  builder => '_build_query_file',
);

sub _build_query_file {
  my $self = shift;
  my $test_script = $0;
  (my $expected_file = $test_script) =~ s/\.t$/.fa/;
  confess "! Error: failed to find expected query file `$expected_file` for test `$test_script`"
    unless -f $expected_file;
  return $expected_file;
}

has 'tmp_dir' => (
  is => 'ro',
  builder => '_build_tmp_dir',
  lazy => 1,
);

sub out_dir {
  my $self = shift;
  return dir( $self->tmp_dir );
}

sub _build_tmp_dir {
  return tempdir( CLEANUP => 1 );
}

has 'max_aln' => (
  is => 'ro',
  default => 1,
);

has 'app' => (
  is => 'ro',
  builder => '_build_app',
  lazy => 1,
  handles => [qw/ run /],
);

sub _build_app {
  my $self = shift;
  my $app = Cath::Tiny::App::Cmd::Seqscan->new(
    in  => $self->query_file,
    out => $self->tmp_dir,
    max_aln => $self->max_aln,
  );
  return $app;
}

sub aln_as_seqio {
  my $self  = shift;
  my $aln_filename = shift;
  my $aln_file = $self->out_dir->file( $aln_filename );
  return Bio::SeqIO->new( -file => $aln_file, -format => 'fasta' );
}

1;
