#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @instructions;
foreach (<>) {
	chomp;
	my @line;
	my @letters = split(//);
	for (my $i=0; $i<@letters; $i++) {
		my $l = $letters[$i];
		if ($l eq 's' or $l eq 'n') {
			die if $i==$#letters;
			$l .= $letters[$i+1];
			$i++;
		}
		push @line, $l;
	}
	push @instructions, \@line;
}

#print Dumper \@instructions;
#
my $DEBUG = 0;

sub getpos {
	my @directions = @_;

	my ($x,$y) = (0,0);
	foreach my $dir (@directions) {
		#printf "  --> %2s (%+2d,%+2d) ", $dir, $x, $y if $DEBUG;
		if ($dir eq 'ne') {
			$x++ if ($y%2==1);
			$y++;
		}
		elsif ($dir eq 'nw') {
			$x-- if ($y%2==0);
			$y++;
		}
		elsif ($dir eq 'e') {
			$x++;
		}
		elsif ($dir eq 'w') {
			$x--;
		}
		elsif ($dir eq 'se') {
			$x++ if ($y%2==1);
			$y--;
		}
		elsif ($dir eq 'sw') {
			$x-- if ($y%2==0);
			$y--;
		}
		#printf "(%+2d,%+2d)\n", $x, $y if $DEBUG;
	}
	return ($x,$y);
}

sub neighbours {
	my $pos = shift or die;

	my ($x,$y) = split(/,/,$pos);

	my @neighbours = (
		xy($x+(($y%2==1)?1:0),$y+1), # ne
		xy($x-(($y%2==0)?1:0),$y+1), # nw
		xy($x-1,$y), # w
		xy($x-(($y%2==0)?1:0),$y-1), # sw
		xy($x+(($y%2==1)?1:0),$y-1), # se
		xy($x+1,$y), # e
	);
	return @neighbours;
}

#printf "neighbours of (0,0): %s\n", join(" ",neighbours("0,0"));
#printf "neighbours of (0,1): %s\n", join(" ",neighbours("0,1"));
#printf "neighbours of (0,-2): %s\n", join(" ",neighbours("0,-2"));
#exit;

sub xy {
	my $x = shift;
	my $y = shift;
	return sprintf("%d,%d",$x,$y);
}

sub fliptile {
	my $tiles = shift or die;
	my $xy = shift or die;
	if (exists $tiles->{$xy}) {
		$tiles->{$xy} = 1 - $tiles->{$xy};
	}
	else {
		$tiles->{$xy} = 1;
	}
}

sub getblacktiles {
	my $tiles = shift or die;
	my %blacktiles;

	foreach my $k (keys %$tiles) {
		if (exists $$tiles{$k} and $$tiles{$k}==1) {
			my ($x,$y) = split(/,/,$k);
			$blacktiles{xy($x,$y)} = 1;
		}
	}

	return \%blacktiles;
}

sub do_day {
	my $tiles = shift or die;
	my $black = getblacktiles($tiles);

	# we need to check all neighbours of all black tiles;
	my %numblackneighbours;
	foreach my $tile (keys %$black) {
		$numblackneighbours{$tile}=0;
	}
	foreach my $tile (keys %$black) {
		foreach my $neighbour (neighbours($tile)) {
			$numblackneighbours{$neighbour}++;
		}
	}

	my @toflip;
	foreach my $tile (reverse sort {
			(split(/,/,$a))[1] <=> (split(/,/,$b))[1] || (split(/,/,$b))[0] <=> (split(/,/,$a))[0]
		} keys %numblackneighbours) {
		my $numblack = $numblackneighbours{$tile};
		my $isblack = $$tiles{$tile} || 0;
		printf "tile %5s is %5s and has %d black neighbours, ",
			$tile, $isblack?"black":"white",$numblack if $DEBUG;
		if ($isblack and ($numblack==0 or $numblack>2)) {
			print "will become white\n" if $DEBUG;
			push @toflip, $tile;
		}
		elsif (not $isblack and $numblack==2) {
			print "will become black\n" if $DEBUG;
			push @toflip, $tile;
		}
		else {
			print "will not flip\n" if $DEBUG;
		}
	}

	foreach my $tile (@toflip) {
		fliptile($tiles,$tile);
	}
}

sub counttiles {
	my $tiles = shift or die;

	my $count_white = 0;
	my $count_black = 0;
	foreach my $k (keys %$tiles) {
		if (exists $$tiles{$k}) {
			if ($$tiles{$k}==1) {
				$count_black++;
			}
			else {
				$count_white++
			}
		}
	}
	return ($count_white,$count_black);
}



# @tiles is a hex grid with $tile[0]->[0] at the center; 0==white, 1==black
# ne of (0,0) is (0, 1), nw of (0,0) is (-1, 1)
# e  of (0,0) is (1, 0), w  of (0,0) is (-1, 0)
# se of (0,0) is (0,-1), sw of (0,0) is (-1,-1)
my %tiles;

foreach my $instr (@instructions) {
	my ($x,$y) = getpos(@$instr);
	printf "(%+3d,%+3d) %s\n", $x, $y, join(",",@$instr);
	fliptile(\%tiles,xy($x,$y));
}

my ($count_white,$count_black) = counttiles(\%tiles);
printf "%d tiles were turned, %d are white, %d are black\n", $count_white+$count_black, $count_white, $count_black;
#print Dumper \%tiles;

for (my $day=1; $day<=100; $day++) {
	do_day(\%tiles);
	my ($count_white,$count_black) = counttiles(\%tiles);
	printf "After day %3d: %4d tiles were turned, %4d are white, %4d are black\n",
		$day, $count_white+$count_black, $count_white, $count_black;
}


