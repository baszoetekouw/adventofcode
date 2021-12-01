#!/usr/bin/perl

use strict;
use warnings;

my $num_ok=0;

foreach (<>) {
	chomp;
	my ($min,$max,$letter,$passwd) = split /-|:? /;
	$passwd =~ s/[^$letter]//g;
	my $len = length($passwd);
	next if ($len<$min or $len>$max);
	my $ok = not ($len<$min or $len>$max);
	print "$_ $len $ok\n";
	$num_ok++;
}

print "$num_ok correct passwords\n";
