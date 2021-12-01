#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @trees;
foreach (<>) {
	chomp;
	my @treeline = split(//);
	push @trees, \@treeline;
}
my $linelen = @{$trees[0]};

# start pos
my ($x,$y) = (0,0);
my $numtrees= 0;
while ($y<@trees) {
	$numtrees++ if ($trees[$y][$x] eq "#");
	$x+=3;
	$y+=1;
	$x -= $linelen if ($x>=$linelen);
}

print "Encountered $numtrees trees\n";

my $mul=1;
foreach ([1,1],[1,3],[1,5],[1,7],[2,1]) {
	my ($dy,$dx) = @$_;

	# start pos
	my ($x,$y) = (0,0);
	my $numtrees= 0;
	while ($y<@trees) {
		$numtrees++ if ($trees[$y][$x] eq "#");
		$x+=$dx;
		$y+=$dy;
		$x -= $linelen if ($x>=$linelen);
	}

	print "Encountered $numtrees trees for ($dx,$dy)\n";
	$mul *= $numtrees;
}
print "result: $mul\n";
