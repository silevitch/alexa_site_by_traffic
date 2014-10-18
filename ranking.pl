#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;

use constant  {
	RANKINGS_PER_PAGE	=> 25,
	MAX_RANKING		=> 500,
	RANKINGS_URL		=> 'http://www.alexa.com/topsites/global;',
	COEFFICIENT		=> 104_943_144_672,
	POWER			=> 1 / -1.008,
};

my $monthly_visitors = $ARGV[0] || die "Please pass in a monthly visitor amount";

# We need to do the inverse of the formula given on http://netberry.co.uk/alexa-rank-explained.htm
my $ranking = int ( ( $monthly_visitors / COEFFICIENT ) ** ( POWER ) );

die "Ranking is not in the top " . MAX_RANKING if ( $ranking >= MAX_RANKING );

my $page = int ( $ranking / RANKINGS_PER_PAGE );

my @sites = scrape( $page );

# need to handle the case where we need to scrape another page
if ( $ranking % RANKINGS_PER_PAGE == 0 ){
	push @sites, scrape( $page + 1 );
}

for my $slot ( $ranking .. $ranking + 1 ) {
	printf("%d:\t%s\n", $slot, $sites[ $slot % RANKINGS_PER_PAGE ] );
}

sub scrape {
	my $page = shift || 0;

	my $html = get( RANKINGS_URL . $page ) or die "Could not scrape $page: $!";

	my @sites = $html =~ m{<a href="/siteinfo/([^"]+)">}g;

	return @sites;
}

