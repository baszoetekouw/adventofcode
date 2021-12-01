#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @data;
foreach (<>) {
	my ($cmd,$num) = m/^([NSEWLRF])(\d+)$/ or die("$_");
	push @data, { cmd=>$cmd, num=>$num};
}

my $east = 0;
my $north = 0;
my $facing = '90'; # 0=north, 90=east

foreach my $d (@data) {
	my $cmd = $d->{'cmd'};
	my $num = $d->{'num'};
	#printf "(pos E%+4d,N%+4d) bearing %+4d, cmd $cmd$num\n", $east, $north, $facing;

	if ($cmd eq 'N') {
		$north += $num;
	}
	elsif ($cmd eq 'S') {
		$north -= $num;
	}
	elsif ($cmd eq 'E') {
		$east += $num;
	}
	elsif ($cmd eq 'W') {
		$east -= $num;
	}
	elsif ($cmd eq 'L' or $cmd eq 'R') {
		$facing +=  ($cmd eq 'R') ? $num : -$num;
		$facing -= 360 if $facing>=360;
		$facing += 360 if $facing<0;
	}
	elsif ($cmd eq 'F') {
		if ($facing==0) {
			$north += $num;
		}
		elsif ($facing==90) {
			$east += $num;
		}
		elsif ($facing==180) {
			$north -= $num;
		}
		elsif ($facing==270) {
			$east -= $num;
		}
		else {
			die("invalid bearing '$facing'");
		}
	}
	else {
		die("Invalid command '$cmd`");
	}
}

print "pos is now (E$east,N$north)\n";
print "Manhatten distance is ".(abs($east)+abs($north))."\n";


$east = 0;
$north = 0;
my $wp_north = 1;
my $wp_east = 10;

foreach my $d (@data) {
	my $cmd = $d->{'cmd'};
	my $num = $d->{'num'};
	#printf "(pos E%+4d,N%+4d) bearing %+4d, cmd $cmd$num\n", $east, $north, $facing;

	if ($cmd eq 'N') {
		$wp_north += $num;
	}
	elsif ($cmd eq 'S') {
		$wp_north -= $num;
	}
	elsif ($cmd eq 'E') {
		$wp_east += $num;
	}
	elsif ($cmd eq 'W') {
		$wp_east -= $num;
	}
	elsif ($cmd eq 'L') {
		for (my $i=0; $i<$num; $i+=90) {
			my $wp_east_old = $wp_east;
			$wp_east = -$wp_north;
			$wp_north = $wp_east_old;
		}
	}
	elsif ($cmd eq 'R') {
		for (my $i=0; $i<$num; $i+=90) {
			my $wp_east_old = $wp_east;
			$wp_east = $wp_north;
			$wp_north = -$wp_east_old
		}
	}
	elsif ($cmd eq 'F') {
		$north += $num * $wp_north;
		$east  += $num * $wp_east;
	}
	else {
		die("Invalid command '$cmd`");
	}
}

print "pos is now (E$east,N$north)\n";
print "Manhatten distance is ".(abs($east)+abs($north))."\n";
