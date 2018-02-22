package App::ElasticSearch::Utilities::QueryString::Nested;
# ABSTRACT: Implement the proposed Elasticsearch nested query syntax

use strict;
use warnings;
use App::ElasticSearch::Utilities::QueryString;
use CLI::Helpers qw(:output);
use namespace::autoclean;

use Moo;
with 'App::ElasticSearch::Utilities::QueryString::Plugin';

has 'qs' => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { App::ElasticSearch::Utilities::QueryString->new() },
    handles  => [qw(expand_query_string)],
);

=example

    nested_path:"field:match AND string"

=cut

my %Reserved = map { $_ => 1 } qw( _prefix_ _exists_ _missing_ );

sub handle_token {
    my ($self,$token) = @_;
    debug(sprintf "%s - evaluating token '%s'", $self->name, $token);

    # split on spaces
    my @subtokens = split /\s+/, $token;

    # check our first token for double colons
    my ($path,$remainder) = split /:"?/, shift @subtokens, 2;

    return if exists $Reserved{$path};

    # If we're nested theres a second colon in there somewhere
    if( $remainder =~ /^[\w\.]+:.+/ ) {
        if( $remainder =~ /^[0-9a-fA-F]{2}(?::[0-9a-fA-F]{2}){2,5}/ ) {
            # This is a mac address, skip it
            return;
        }
        $subtokens[-1] =~ s/"$// if @subtokens;
        debug(sprintf "%s - Found nested query, path is %s, remainder: %s", $self->name, $path,$remainder);
        my $q = $self->expand_query_string($remainder,@subtokens);
        debug_var($q->query);
        return [{ nested => {query => $q->query, path => $path}}];
    }
    return;
}

# Return True;
1;

__END__

=head1 SYNOPSIS

=head2 App::ElasticSearch::Utilities::QueryString::Nested

Implement the proposed nested query syntax early.

