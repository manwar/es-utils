package App::ElasticSearch::Utilities::QueryString::IP;
# ABSTRACT: Expand IP CIDR Notation to ES ranges

use strict;
use warnings;

# VERSION

use Net::CIDR::Lite;
use namespace::autoclean;

use Moo;
with 'App::ElasticSearch::Utilities::QueryString::Plugin';

=for Pod::Coverage handle_token

=cut

sub handle_token {
    my ($self,$token) = @_;
    if( my ($term,$match) = split /\:/, $token, 2 ) {
        if($term =~ /_ip$/ ) {
            if($match =~ m|^\d{1,3}(\.\d{1,3}){1,3}(/\d+)$|) {
                my $cidr = Net::CIDR::Lite->new();
                $cidr->add($match);
                my @range = split /-/, ($cidr->list_range)[0];
                return { query_string => sprintf("%s:[%s TO %s]", $term, @range) };
            }
        }
    }
    return;
}

1;
__END__

=head1 SYNOPSIS

=head2 App::ElasticSearch::Utilities::QueryString::IP

If a field is an IP address uses CIDR Notation, it's expanded to a range query.

    src_ip:10.0/8 => src_ip:[10.0.0.0 TO 10.255.255.255]

