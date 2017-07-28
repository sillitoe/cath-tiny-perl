package Cath::Tiny::Utils;

=head1 NAME

Cath::Tiny::Utils - useful utility functions

=head1 SYNOPSIS

  use Cath::Tiny::Utils qw/ all /;

  guess_db_source_from_domain_id( '1cukA01' ); # 'CATH'

=cut

use Cath::Tiny::Types -all;

=head2 guess_db_source_from_domain_id( $domain_id )

Try to guess the source database for a particular domain id. Returns
an uppercase string or `undef` if not recognised.

  'CATH', 'SCOP', 'UNIPROT', 'ECOD'

Returns: Str | undef

=cut

sub guess_db_source_from_domain_id {
  my $id = shift;
  my $type = is_CathDomainIDStr( $id )    ? 'CATH'
           : is_ScopDomainIDStr( $id )    ? 'SCOP'
           : is_UniprotDomainIDStr( $id ) ? 'UNIPROT'
           : is_EcodDomainIDStr( $id )    ? 'ECOD'
           : undef;

  return $type;
}

1;
