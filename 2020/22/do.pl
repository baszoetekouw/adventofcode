#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @player1;
my @player2;
my $p=0;
foreach (<>) {
	chomp;
	next if /^$/;
	if (/^Player (\d):/) {
		$p=$1;
		next;
	}
	push @player1, $_ if $p==1;
	push @player2, $_ if $p==2;
}

printf "Player1: %s\n", join(",",@player1);
printf "Player2: %s\n", join(",",@player2);

for (my $i=0; @player1 and @player2; $i++) {
	print "-- Round $i --\n";
	printf "Player 1's deck: %s\n", join(",",@player1);
	printf "Player 2's deck: %s\n", join(",",@player2);

	my $card1 = shift @player1;
	my $card2 = shift @player2;

	print "Player 1 plays $card1\n";
	print "Player 2 plays $card2\n";

	my $winner = $card2>$card1 ? 2 : 1;
	print "Winner: player $winner\n";

	if ($winner==1) {
		push @player1, $card1, $card2;
	}
	else {
		push @player2, $card2, $card1;
	}
	print "\n";
}

print "Results\n";
printf "Player1: %s\n", join(",",@player1);
printf "Player2: %s\n", join(",",@player2);

sub score {
	my @deck = @_;
	my $score = 0;
	for (my $i=0; $i<@deck; $i++) {
		$score += ($i+1) * $deck[$#deck-$i];
	}
	return $score;
}
printf "Player 1 score: %d\n", score(@player1);
printf "Player 2 score: %d\n", score(@player2);
