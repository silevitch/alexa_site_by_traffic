#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;

my $monthly_visitors = $ARGV[0];

# We need to do the inverse of the formula given on http://netberry.co.uk/alexa-rank-explained.htm:
# $monthly_visitors = 104_943_144_672 * ( $ranking ^ -1.008)
#
my $ranking = int ( ( $monthly_visitors / 104_943_144_672 ) ** ( 1 / -1.008 ) );

my $page = int ( $ranking / 25 );

my @sites = scrape( $page );

if ( int ( $ranking % 25 ) == 0 ){
	push @sites, scrape( $page + 1 );
}

for my $i ( $ranking .. $ranking + 1 ) {
	printf("%d:\t%s\n", $i, $sites[ $i % 25 ] );
}

sub scrape {
	my $page = shift || 0;

	my $html = get('http://www.alexa.com/topsites/global;' . $page) or die "Could not scrape: $!";

	my @sites = $html =~ m{<a href="/siteinfo/([^"]+)">}g;

	return @sites;
}

