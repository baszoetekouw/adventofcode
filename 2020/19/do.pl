#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rules;
my @msg;
my $state = 0;
while (my $line=<>) {
	chomp $line;
	if ($line eq '') {
		$state++;
		next;
	}
	if ($state==0) {
		my ($num, $rule) = split(/: /, $line);
		$rule =~ s/"//g;
		if ($rule =~ m{\|}) {
			$rule = "(?: $rule )";
		}
		$rules[$num] = $rule;
	}
	else {
		push @msg, $line;
	}
}

print Dumper \@rules;
print Dumper \@msg;

{

	my $matcher = $rules[0];
	my $n=0;
	print "--> /$matcher/\n";
	while ($matcher =~ m/\d/) {
		my @parts = split(/\s+/, $matcher);
		foreach my $p (@parts) {
			if ($p =~ m/^\d+$/) {
				print "    Replacing '$p' by '$rules[$p]'\n";
				$p = $rules[$p];
			}
		}
		$matcher = join(" ", @parts);
		print "--> /$matcher/\n";
		last if (++$n>=100);
	}

	my $re = qr/^$matcher$/x;
	my $num = 0;
	foreach my $m (@msg) {
		my $result = ($m =~ $re) ? 1 : 0;
		$num++ if $result;
		printf "$m %s\n", $result ? "matches" : "does not match";
	}

	print "There were $num matches\n";
}

print "\n== part2 ==\n\n";

$rules[8] = '42 +';
$rules[11] =  '(?: 42 31 | 42 {2} 31 {2} | 42 {3} 31 {3} | 42 {4} 31 {4} | 42 {5} 31 {5} | 42 {6} 31 {6} | 42 {7} 31 {7} | 42 {8} 31 {8} | 42 {9} 31 {9} | 42 {10} 31 {10} | 42 {11} 31 {11} )';

my $matcher2 = $rules[0];
my $n=0;
print "--> /$matcher2/\n";
while ($matcher2 =~ m/\d/) {
	my @parts = split(/\s+/, $matcher2);
	foreach my $p (@parts) {
		if ($p =~ m/^\d+$/) {
			print "    Replacing '$p' by '$rules[$p]'\n";
			$p = $rules[$p];
		}
	}
	$matcher2 = join(" ", @parts);
	print "--> /$matcher2/\n";
	last if (++$n>=100);
}

my $re2 = qr/^$matcher2$/x;
my $num2 = 0;
foreach my $m (@msg) {
	my $result = ($m =~ $re2) ? 1 : 0;
	$num2++ if $result;
	printf "$m %s\n", $result ? "matches" : "does not match";
}
print "There were $num2 matches\n";

