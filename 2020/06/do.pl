#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

$/ = "\n\n";

my @groups;
foreach (<>) {
	chomp;
	push @groups, [split(/\s+/)];
}


my $n = 0;
my $m = 0;
foreach my $group (@groups) {
	my %answers;
	foreach $a (split(//,join("",@$group))) {
		$answers{$a} += 1;
	}
	# anyone answered yes
	$n += scalar keys %answers;
	# everyone answered yes
	$m += scalar grep { $_==scalar @$group } values %answers;
}

print "cumulative number of unique answers per group: $n\n";
print "average number of unique answers per group: ". ($n/@groups) . "\n";;
print "cumulative number of identical answers per group: $m\n";;
print "average number of identical answers per group: ". ($m/@groups) . "\n";;

