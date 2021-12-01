#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/max/;

my @code;
foreach (<>) {
	chomp;
	my ($op,$arg) = split(/\s+/);
	push @code, { op => $op, arg => int($arg), instr => $_ } if $arg;
}

for (my $i=0; $i<@code; $i++) {
	print "$i $code[$i]->{op} $code[$i]->{arg}\n";
}

print "\n====\nRunning\n====\n";

for (my $i=0; $i<@code; $i++) {
	my $oldop = $code[$i]->{op};
	if ($code[$i]->{op} eq 'nop') {
		$code[$i]->{op} = 'jmp';
	}
	elsif ($code[$i]->{op} eq 'jmp') {
		$code[$i]->{op} = 'nop';
	}
	else {
		next
	}
	print "Change instruction $i (was: $code[$i]->{instr}\n";

	my $ip = 0;
	my $acc = 0;
	my %seen;
	while (not exists $seen{$ip} and $ip<@code) {
		$seen{$ip}++;
		my $op  = $code[$ip]->{op};
		my $arg = $code[$ip]->{arg};
		printf "   %3d : %3s %+04i   %+4i\n", $ip, $op, $arg, $acc;
		if ( $op eq 'nop' ) {
			$ip++;
		}
		elsif ($op eq 'jmp') {
			$ip += $arg;
		}
		elsif ($op eq 'acc') {
			$acc += $arg;
			$ip++;
		}
		else {
			die("Unkown operation `$op'\n");
		}
	}

	# reset changed instruction
	$code[$i]->{op} = $oldop;

	if (not $ip<@code) {
		print "End of program!\n";
		print "Accumulator value is $acc\n";
		last;
	}
	else
	{
		print "Repeated line $ip: $code[$ip]->{op} $code[$ip]->{arg}\n";
	}
}



