use Test::More;

use strict;
use warnings;
use Data::Dumper;

use Cath::Tiny::Test;

use_ok( 'Cath::Tiny::MediaWiki' );

my $mw = Cath::Tiny::MediaWiki->new();

my $page = $mw->get_page( { title => 'CATH_database' } )
  || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};

print Dumper( $page );

done_testing;


# print the name of each article
sub print_articles {
  my ($ref) = @_;
  foreach (@$ref) {
    print "$_->{title}\n";
  }
}
