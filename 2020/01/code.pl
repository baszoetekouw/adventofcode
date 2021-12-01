#!/usr/bin/perl

use strict;
use warnings;

my %input;

while (<STDIN>) {
	chomp;
	next if $_<0 or $_>2020;
	$input{$_} = 1
}

foreach my $i (sort {$a<=>$b} keys %input)
{
	last if $i > 1010;
	my $j = 2020-$i;
	if (exists($input{$j})) {
		print "$i $j ", $i*$j, "\n";
		last;
	}
}

my @input = sort {$a<=>$b} keys %input;
for (my $i = 0; $i<@input; $i++)
{
	my $a = $input[$i];
	my $rest = 2020-$a;

	for (my $j=$i+1; $j<@input; $j++)
	{
		my $b = $input[$j];
		my $c = 2020-$a-$b;
		last if ($c<=0);
		last if ($c<$b);

		#print "  $a $b\n";

		if (exists($input{$c})) {
			print "$a $b $c ", $a*$b*$c, "\n";
			last;
		}
	}

}



