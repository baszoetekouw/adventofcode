#!/usr/bin/perl

use strict;
use warnings;

my $num_ok=0;

foreach (<>) {
	chomp;
	my ($pos1,$pos2,$letter,$passwd) = split /-|:? /;
	$pos1--;
	$pos2--;
	my @chars = split(//,$passwd);
	my ($c1,$c2) = @chars[$pos1,$pos2];

	my $ok = ($c1 eq $letter xor $c2 eq $letter) ? 1 : 0;
	next unless $ok;

	print "$_ $ok $c1 $c2\n";

	$num_ok++

}

print "$num_ok correct passwords\n";
