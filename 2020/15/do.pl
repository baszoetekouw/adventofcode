#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $line = <>;
chomp $line;
my @start = split(/,/, $line);

my %numbers;

my $turn = 1;
my $lastnum;
my $laststatus;
foreach my $n (@start) {
	printf "Turn %d: %d\n", $turn, $n;
	$lastnum = $n;
	$laststatus = $numbers{$n};
	$numbers{$n} = $turn;
	$turn++
}
for (; $turn<=30000000; $turn++) {
	my $n;
	#printf "Turn %d: last=%d, seen before: %d\n", $turn, $lastnum, $laststatus || -1;
	if ($laststatus) {
		$n = ($turn-1)  - $laststatus;
	} else {
		$n = 0;
	}
	$laststatus = $numbers{$n};
	$lastnum = $n;
	$numbers{$n} = $turn;

	printf("Turn %d (%.0f%%): %d\n", $turn, 100*$turn/30000000, $n) if ($turn%1000==0);

}
