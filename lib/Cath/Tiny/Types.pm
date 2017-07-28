package Cath::Tiny::Types;

use Type::Library
  -base,
  -declare => qw/
    ArrayOfSegments
    ArrayOfInts
    IdLookup
    AnyDomainIDStr
    CathDomainIDStr
    ScopDomainIDStr
    EcodDomainIDStr
    UniprotDomainIDStr
    PdbCodeStr
    CathSuperfamilyIDStr
    Domain
    Segment
    Version
    Residue
  /;

use warnings;
use Type::Utils -all;
use Types::Standard -types;
use List::Util qw/ all /;
use Carp qw/ croak /;

#use base 'Exporter::Tiny';

declare CathDomainIDStr,
  where { ! ref $_ && $_ =~ /^[0-9][a-z0-9]{3}[a-zA-Z][0-9]{2}$/ },
    message { "$_ doesn't look like a CATH domain id" };

declare ScopDomainIDStr,
  where { ! ref $_ && $_ =~ /^add_scop_regexp_here$/ },
    message { "$_ doesn't look like a SCOP domain id" };

declare EcodDomainIDStr,
  where { ! ref $_ && $_ =~ /^add_ecod_regexp_here$/ },
    message { "$_ doesn't look like a ECOD domain id" };

declare UniprotDomainIDStr,
  where { ! ref $_ && $_ =~ /^add_uniprot_regexp_here$/ },
    message { "$_ doesn't look like a UniProtKB domain id" };

declare AnyDomainIDStr,
  where { ! ref $_ && (
      is_CathDomainIDStr( $_ )
      || is_ScopDomainIDStr( $_ )
      || is_UniprotDomainIDStr( $_ )
      || is_EcodDomainIDStr( $_ )
    )
  };

declare PdbCodeStr,
  where { ! ref $_ && $_ =~ /^[0-9a-zA-Z]{4}$/ },
    message { "$_ doesn't look like a PDB code" };

declare CathSuperfamilyIDStr,
  where { ! ref $_ && $_ =~ /^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$/ },
    message { "$_ doesn't look like a CATH superfamily id" };

class_type Domain,  { class => "Cath::Tiny::Domain" };
class_type Version, { class => "Cath::Tiny::Version" };
class_type Segment, { class => "Cath::Tiny::Segment" };
class_type Residue, { class => "Cath::Tiny::Residue" };

coerce Segment,
  from Str,
    via {
      /(\-?[0-9]+[A-Z]?)-(-?[0-9]+[A-Z]?)/
        or croak "Error: string '$_' does not look like a valid residue range";
      return Cath::Tools::Segment->new( start => $1, stop => $2 );
    };

declare IdLookup,
  where { ref $_ eq 'HASH' && all { ! ref $_ } values %$_ };

coerce IdLookup,
  from ArrayRef,
    via {
      return { map { ($_ => 1) } @$_ };
    };

declare ArrayOfSegments,
   where { ref $_ eq 'ARRAY' && all { is_Segment($_) } @$_ },
   message { "$_ doesn't look like an ArrayRef of Cath::Tiny::Segment to me" };

declare ArrayOfInts,
   where { ref $_ eq 'ARRAY' && all { is_Int($_) } @$_ },
   message { "$_ doesn't look like an ArrayRef of Ints to me"}

coerce ArrayOfSegments,
  from Str,
    via {
      require Cath::Tiny::Segment;
      my @segs = map { Cath::Tiny::Segment->new_from_pdb_string($_) } split( /,/, $_ );
      return \@segs;
    };

1;
