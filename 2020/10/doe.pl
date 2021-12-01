#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/ min max /;
use Data::Dumper;
use utf8;

sub calc_factor {
	my @nums = @_;
	return 1 if @nums<3;
	return 2 if @nums==3;
	return 4 if @nums==4;
	return 7 if @nums==5;
	die;
}

my @adapters = (0);
foreach (<>) {
	push @adapters, int($_);
}
push @adapters, max(@adapters)+3;

my @sorted = sort {$a<=>$b} @adapters;
#print join("\n",@sorted);

my %diffs;
for (my $i=1; $i<@sorted; $i++) {
	my $delta = $sorted[$i] - $sorted[$i-1];
	$diffs{$delta}++;
}
#print Dumper \%diffs;

printf "result is %d × %d = %d\n", $diffs{1}, $diffs{3}, $diffs{1}*$diffs{3};

my @clusters;
{
	my @cluster = ($sorted[0]);
	for (my $i=1; $i<@sorted; $i++) {
		my $delta = $sorted[$i] - $sorted[$i-1];
		if ($delta==3) {
			push @clusters, [@cluster];
			@cluster = ();
		}
		push @cluster, $sorted[$i];
	}
}

print Dumper \@clusters;

print join("\n",map { scalar(@$_)} @clusters);

my @factors;
foreach my $cluster (@clusters) {
	push @factors, calc_factor(@$cluster);
}

print Dumper \@factors;

my $mul = 1;
$mul *= $_ for @factors;
print "Total number of possibilities: $mul",


