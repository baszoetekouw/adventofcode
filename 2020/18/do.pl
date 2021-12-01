#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @lines;
while (my $line = <>) {
	chomp $line;
	next if $line =~ /^\s*$/;

	$line =~ s/\(/\( /g;
	$line =~ s/\)/ \)/g;
	my @tokens = split(/ +/, $line);

	push @lines, \@tokens;
}

#print Dumper \@lines; exit;


sub parse {
	my $tokens = shift or die;
	my $start = shift || 0;

	my $result = 0;
	my $op = '+';
	for (my $i=$start; $i<@$tokens; $i++) {
		next unless exists $$tokens[$i] and defined  $$tokens[$i];
		my $token = $$tokens[$i];

		if ($token eq '+') {
			$op = '+'
		}
		elsif ($token eq '*') {
			$op = '*'
		}
		elsif ($token eq '(') {
			parse($tokens,$i+1);
		}
		elsif ($token eq ')') {
			$$tokens[$i] = $result;
			return;
		}
		elsif ($token =~ /^\d+$/) {
			if (not defined($op)) {
				print Dumper($tokens);
				die("found $token at pos $i with result '$result' but no operator defined\n")
			}
			if ($op eq '+') {
				$result += $token;
			}
			elsif ($op eq '*') {
				$result *= $token;
			}
			else {
				die("unsupported operator '$op'\n");
			}
			$op = undef;
		}
		else {
			die("unsupported token '$token'\n");
		}
		$$tokens[$i] = undef;

	}
	return $result
}

my $total = 0;
foreach my $tokens (@lines) {
	printf "%s becomes ", join(" ",@$tokens);
	my $result = parse($tokens,0);
	printf "%d\n", $result;
	$total += $result;
}
print "Total is $total\n";
