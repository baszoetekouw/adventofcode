#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::MoreUtils qw/ last_index /;

my $debug = 0;

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

sub tokenize {
	my @expression = @_ or die;

	my @tokens;
	TOKENS:
	for (my $i=0; $i<@expression; $i++) {
		if ($expression[$i] eq '(') {
			my $depth = 1;
			my @thistoken;
			for (my $j=$i+1; $j<@expression; $j++) {
				if ($expression[$j] eq '(') {
					$depth++;
				}
				if ($expression[$j] eq ')') {
					if ($depth==1) {
						if ($i+1>=$j-1) {
							print "{ ". join(",", @expression). " }\n";
							die("Parse error (i=$i, j=$j)")
						}
						push @tokens, [@expression[($i+1)..($j-1)]];
						$i = $j;
						next TOKENS;
					}
					else {
						$depth--;
					}
				}
			}
		}
		elsif ($expression[$i] eq '(') {
			die("Parse error: unexpected ) at pos $i");
		}
		else {
			push @tokens, [$expression[$i]];
		}
	}
	if ($debug) {
		print "Tokeneized '". join("", @expression)."' to: ";
		foreach my $t (@tokens) {
			print "[" . join("", @$t) . "] ";
		}
		print "\n";
	}
	return @tokens;
}

sub flat {  # no prototype for this one to avoid warnings
    return map { ref eq 'ARRAY' ? flat(@$_) : $_ } @_;
}

sub t2s {
	my @tokens = flat(@_);
	my $str = "";
	foreach my $t (@tokens) {
		$str .= $t;
	}
	return $str;
}

sub t2e {
	my @tokens = @_;
	my @expression;
	foreach my $t (@tokens) {
		if (@$t==1) {
			push @expression, $$t[0];
		}
		else {
			push @expression, '(', @$t, ')';
		}
	}
	return @expression;
}

sub calc {
	my @expression = flat(@_) or die("called calc(".join(",",@_).")");

	my @tokens = tokenize(@expression);

	if (@tokens==1) {
		if (@{$tokens[0]}==1) {
			print "Single token $tokens[0]->[0]\n" if $debug;
			return $tokens[0]->[0];
		}
		else
		{
			return calc(@{$tokens[0]});
		}
	}

	my $mul_idx = last_index { @$_==1 and $$_[0] eq '*' } @tokens;
	if ($mul_idx!=-1) {
		print "Multiplication\n" if $debug;
		my @tleft  = @tokens[0..$mul_idx-1];
		my @tright = @tokens[$mul_idx+1..$#tokens];
		printf "  calc  (%s) * (%s)\n", t2s(@tleft), t2s(@tright) if $debug;
		my $left  = calc( t2e(@tleft)  );
		my $right = calc( t2e(@tright) );
		my $result = $left * $right;
		printf " = $left * $right = $result\n" if $debug;
		return $result;
	}

	my $add_idx = last_index { @$_==1 and $$_[0] eq '+' } @tokens;
	if ($add_idx!=-1) {
		print "Addition\n" if $debug;
		my @tleft  = @tokens[0..$add_idx-1];
		my @tright = @tokens[$add_idx+1..$#tokens];
		printf "  calc  (%s) + (%s)\n", t2s(@tleft), t2s(@tright) if $debug;
		my $left  = calc( t2e(@tleft) );
		my $right = calc( t2e(@tright) );
		my $result = $left + $right;
		printf " = $left + $right = $result\n" if $debug;
		return $result;
	}

	die();
}

my $total = 0;
foreach my $tokens (@lines) {
	my $result = calc(@$tokens);
	printf "%s becomes ", join(" ",@$tokens);
	printf "%d\n", $result;
	$total += $result;
}
print "Total is $total\n";
