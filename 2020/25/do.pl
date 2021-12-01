#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

sub transform {
	my $input = shift;
	my $subject = shift || 7;
	return ($subject*$input)%20201227;
}

sub find_privkey {
	my $pubkey = shift;
	my $loops = shift;

	my $encryption = 1;
	for (my $i=0; $i<$loops; $i++) {
		$encryption = ($encryption * $pubkey) % 20201227
	}
	return $encryption;
}

sub find_loops {
	my $pubkey = shift;

	my $tmp = 1;
	my $loop = 0;
	while (++$loop) {
		$tmp = transform($tmp);
		#printf "--> loop=%3d key=%d\n", $loop, $tmp;
		last if $tmp==$pubkey;
		#die if ($loop>100000);
	}
	return $loop;
}

my $pubkey_card = 19774466;
my $pubkey_door = 7290641;

# example
#my $pubkey_card = 5764801;
#my $pubkey_door = 17807724;

my $loops_card = find_loops($pubkey_card);
my $loops_door = find_loops($pubkey_door);

print "Card: $loops_card loops\n";
print "Door: $loops_door loops\n";

my $secretkey1 = find_privkey($pubkey_card,$loops_door);
my $secretkey2 = find_privkey($pubkey_door,$loops_card);

print "Encryption key 1: $secretkey1\n";
print "Encryption key 2: $secretkey2\n";
