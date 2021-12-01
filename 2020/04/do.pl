#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(any);
use Data::Dumper;

sub is_valid($$) {
	my ($key,$val) = @_;
	if ($key eq "byr") {
		return 1 if $val>=1920 and $val<=2002;
	}
	elsif ($key eq "iyr") {
		return 1 if $val>=2010 and $val<=2020;
	}
	elsif ($key eq "eyr") {
		return 1 if $val>=2020 and $val<=2030;
	}
	elsif ($key eq "hgt") {
		return 1 if $val=~/^(\d+)(cm|in)$/
			and (($2 eq "cm" and $1>=150 and $1<=193) or ($2 eq "in" and $1>=59 and $1<=76));
	}
	elsif ($key eq "hcl") {
		return 1 if $val=~/^#[0-9a-f]{6}$/;
	}
	elsif ($key eq "ecl") {
		my @allowed = qw/ amb blu brn gry grn hzl oth /;
		return 1 if any { $_ eq $val } @allowed;
	}
	elsif ($key eq "pid") {
		return 1 if $val =~ /^\d{9}$/;
	}

	return undef;
}

local $/ = "\n\n";

my @passports;
foreach (<>) {
	my %fields;
	while (/(\w{3}):(.+?)\s/gc) { $fields{$1} = $2; }
	push @passports, \%fields;
}

print "Found ".scalar(@passports)." passports\n";


my @REQ = qw/ byr iyr eyr hgt hcl ecl pid /;
my $n1 = 0;
my $n2 = 0;

PASSPORTS:
foreach my $p (@passports)
{
	my $ok1 = 1;
	foreach my $f (@REQ) {
		$ok1 = 0 unless exists $$p{$f};
		last unless $ok1;
	}
	my $ok2 = 1;
	foreach my $f (@REQ) {
		$ok2 = 0 unless exists $$p{$f} and is_valid($f,$$p{$f});
		last unless $ok2;
	}
	$n1++ if $ok1;
	$n2++ if $ok2;
}

print "$n1 passports have the correct fields\n";
print "$n2 passports have valid fields\n";
