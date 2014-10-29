#!/usr/bin/env perl

#
# rankings.pl [monthly_visits]
# Simple script takes a monthly visits parameter and returns where
# that amount would fall on Alexa's top 500.
#

use strict;
use warnings;

use version; our $VERSION = qv('1.0.0');

use LWP::Simple;
use Carp qw(croak);
use Readonly;

Readonly my $RANKINGS_PER_PAGE => 25;
Readonly my $MAX_RANKING       => 500;
Readonly my $RANKINGS_URL      => 'http://www.alexa.com/topsites/global;';
Readonly my $COEFFICIENT       => 104_943_144_672;
Readonly my $POWER             => 1 / -1.008;

my $monthly_visitors = $ARGV[0]
  || croak 'Please pass in a monthly visitor amount';

# We need to do the inverse of the formula given on http://netberry.co.uk/alexa-rank-explained.htm
my $ranking = int( ( $monthly_visitors / $COEFFICIENT )**($POWER) );

croak 'Ranking is not in the top ' . $MAX_RANKING
  if ( $ranking >= $MAX_RANKING );

my $page = int( $ranking / $RANKINGS_PER_PAGE );

my @sites = scrape($page);

# need to handle the case where we need to scrape another page
if ( $ranking % $RANKINGS_PER_PAGE == 0 ) {
    push @sites, scrape( $page + 1 );
}

for my $slot ( $ranking .. $ranking + 1 ) {
    printf "%d:\t%s\n", $slot, $sites[ $slot % $RANKINGS_PER_PAGE ];
}

sub scrape {
    my $number = shift || 0;

    my $html = get( $RANKINGS_URL . $number )
      or croak "Could not scrape page $number";

    my @found_sites = $html =~ m{<a href="/siteinfo/([^"]+)">}xmsg;

    return @found_sites;
}
