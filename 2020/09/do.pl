#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/ max min /;

sub check_pool($$) {
	my $n = shift or die;
	my $pool = shift or die;

	foreach my $a (keys $pool) {
		my $b = $n - $a;
		return 1 if exists($pool->{$b});
	}
	return undef;
}

my @numbers;
while (<>) {
	chomp;
	push @numbers, int($_);
}

my $target;
for (my $i = 25; $i<@numbers; $i++) {
	my %pool = map { $_ => 1 } @numbers[$i-25..$i-1];
	die("only ".(scalar keys %pool)." entries in pool at line $i") unless 25 == keys %pool;
	my $num = $numbers[$i];
	if (not check_pool($num, \%pool)) {
		print "num $num at line $i fails\n";
		$target = $num;
		last;
	}
}


for (my $i=0; $i<@numbers; $i++) {
	my $sum = 0;
	for (my $j=$i; $j<@numbers; $j++) {
		$sum += $numbers[$j];
		if ($sum==$target) {
			print "Found target at lines $i..$j!\n";
			my @range = sort {$a<=>$b} @numbers[$i..$j];
			print join('+',@range), "\n";
			printf "result = %d+%d=%d\n", $range[0], $range[-1], $range[0]+$range[-1];
			exit(0);
		}
	}
}
