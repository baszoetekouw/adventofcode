#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw/ sha256_hex /;

sub chksum {
	my $deck1 = shift or die;
	my $deck2 = shift or die;

	my $str = join(",",@$deck1) . "|" . join(",",@$deck2);
	return sha256_hex($str);
}

sub game
{
	my $game = shift;
	my $deck1 = $_[0];
	my $deck2 = $_[1];

	printf "== Game %d ==\n", $game;

	my $gamewinner = undef;
	my %decks_seen;
	for (my $round=1; @$deck1 and @$deck2; $round++) {
		print "\n";
		print "-- Round $round (Game $game) --\n";

		printf "Player 1's deck: %s\n", join(",",@$deck1);
		printf "Player 2's deck: %s\n", join(",",@$deck2);

		my $deck_chksum = chksum($deck1,$deck2);
		if (exists $decks_seen{$deck_chksum}) {
			printf "Decks are identical to round %d\n", $decks_seen{$deck_chksum};
			print "Player 1 wins game\n";
			$gamewinner = 1;
			last;
		}
		else {
			$decks_seen{$deck_chksum} = $round;
		}

		my $card1 = shift @$deck1;
		my $card2 = shift @$deck2;

		print "Player 1 plays $card1\n";
		print "Player 2 plays $card2\n";

		my $winner;

		if ($card1<=@$deck1 and $card2<=@$deck2) {
			my @newdeck1 = @$deck1[0..($card1-1)];
			my @newdeck2 = @$deck2[0..($card2-1)];
			print "Playing a sub-game to determine the winner...\n\n";
			$winner = game($game+1,\@newdeck1,\@newdeck2);
		}
		else {
			$winner = $card2>$card1 ? 2 : 1;
		}

		print "Player $winner wins round $round of game $game\n";

		if ($winner==1) {
			push @$deck1, $card1, $card2;
		}
		else {
			push @$deck2, $card2, $card1;
		}
		print "\n";

		$gamewinner = @$deck1 ? 1 : 2;
	}

	print "Player $gamewinner wins Game $game\n";
	printf "Back to game %d\n", $game-1 unless $game==1;
	return $gamewinner;
}

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

game(1,\@player1,\@player2);

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
