package Cath::Tiny::Cluster::NamingScheme::RepresentativeUniprotDescription;

use Moo;
use List::MoreUtils qw/ uniq /;
use Types::Standard -types;

with 'Cath::Tiny::Cluster::NamingScheme::BaseRole';

has fixed_term_count => ( is => 'ro', isa => Num, default => sub { 7 } );

=head2 score_entries

returns a sorted, annotated set of member data structures

=cut

sub score_entries {
  my $self = shift;

  my $cluster = $self->cluster;

  my @members = $cluster->list_all_members;

  my $fixed_term_count = $self->fixed_term_count;

  my %terms_count;

  my %ignore_terms = map { ($_ => 1) } $self->list_all_ignore_terms;

  my $sp_count = grep { $_->swissprot } @members;

  my %entries_by_id;

  # get distribution of terms
  foreach my $member ( @members ) {
    my $id = $member->id;

    my @normalised_terms = _normalise_terms( $member->name );

    my $entry = $self->new_entry(
      id           => $id,
      member       => $member,
      terms        => \@normalised_terms,
      raw_score    => 0,
      scored_terms => {},
      weighting    => 0,
      score        => 0,
      raw_score    => 0,
    );

    $entries_by_id{ $id } = $entry;

    # if terms are repeated within the same entry then only count once
    my @uniq_terms = uniq @normalised_terms;

    for my $term ( @uniq_terms ) {
      $terms_count{ $term } += exists $ignore_terms{ $term } ? 0 : 1;
    }
  }

  # score this description according to popularity of terms across the cluster
  foreach my $entry ( values %entries_by_id ) {
    my $score;
    my $terms = $entry->terms;
    my @uniq_terms = uniq @$terms;
    foreach my $term ( @uniq_terms ) {
      $score += $terms_count{ $term };
    }
    $entry->raw_score( $score );
  }

  my @valid_entries = grep { $_->raw_score > 0 } values %entries_by_id;

  # penalise descriptions that have a large difference in the number of terms
  # (w.r.t the average number of terms for sequences in this cluster)
  my $average_term_count = 0;
  foreach my $entry ( @valid_entries ) {
    my $terms = $entry->terms;
    $average_term_count += scalar @{ $terms };
    my %terms_seen;
    for my $term ( @$terms ) {
      $entry->scored_terms->{ $term }++;
    }
  }

  $average_term_count = scalar @valid_entries ? $average_term_count / scalar @valid_entries : 1;

  if ( $fixed_term_count ) {
    $average_term_count = $fixed_term_count;
  }

  foreach my $entry ( @valid_entries ) {
    my $term_count = scalar @{ $entry->terms };
    my $weighting = ($average_term_count - abs($average_term_count - $term_count)) / $average_term_count;
    $entry->weighting( $weighting );
    $entry->score( $entry->raw_score * $weighting );
  }

  my @sorted_entries = reverse sort { $a->score <=> $b->score } @valid_entries;

  return \@sorted_entries;
}

1;
