package Text::FastSearch;

use 5.006;
use strict;
use warnings;
use Errno;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);
our @EXPORT = qw(search_string search_file strindex);
our $VERSION = '1.0';

sub strindex {
    return Text::FastSearch::_strindex (@_);
}

sub search_string {
    my $results_ref = Text::FastSearch::_search_string (@_);
    return (wantarray ? @{$results_ref} : $results_ref) if $results_ref;
    return undef;
}

sub search_file {
    my $results_ref = Text::FastSearch::_search_file (@_);
    return (wantarray ? @{$results_ref} : $results_ref) if $results_ref;
    return undef;
}

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($!{EINVAL}) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    croak "Your vendor has not defined Text::FastSearch macro $constname";
	}
    }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
	if ($] >= 5.00561) {
	    *$AUTOLOAD = sub () { $val };
	}
	else {
	    *$AUTOLOAD = sub { $val };
	}
    }
    goto &$AUTOLOAD;
}

bootstrap Text::FastSearch $VERSION;

1;
__END__

=head1 NAME

Text::FastSearch - Fast string search library.

=head1 SYNOPSIS

    use Text::FastSearch;

    @offsets = search_string ($pattern, $text);
    $offset = strindex ($pattern, $text);
    @offsets = search_file ($pattern, $filename);
   
=head1 DESCRIPTION

Search_string () searches for exact matches of a string within
another string, without performing regular expression pattern
matching.  Strindex () searches for the first occurence of an exact
pattern within the text.  Search_file () searches a file for
occurrences of the exact text in the file.

In a list context, search_string () and search_file () return a list
of file offsets where the pattern occurs in the search text, or a
reference to the list of offsets in scalar context.  Strindex ()
returns the offset of the first occurence of the pattern in the text.
The subroutines return undef if the search pattern is not found.

=head1 EXPORTS

=head2 strindex (I<pattern>, I<text>)

Returns the offset of the first occurence of I<pattern> in I<text>, or
undef if I<pattern> is not found.

=head2 search_string (I<pattern>, I<text>)

Returns a list of offsets in I<text> where I<pattern> is found, or
undef.

=head2 search_file (I<pattern>, I<file_name>)

Returns a list of offsets in the input file where I<pattern> is found,
or undef.

=head1 VERSION AND CREDITS

$Id: FastSearch.pm,v 1.2 2006/04/28 08:03:35 kiesling Exp $

Copyright © 2005-2006 Robert Kiesling, rkies@cpan.org.

Licensed under the same terms as Perl.  Refer to the file, "Artistic,"
for details.

The search strategies are from the Boyer-Moore search algorithm as
described in Michael Abrash's I<Graphics Programming Black Book.>

=cut
