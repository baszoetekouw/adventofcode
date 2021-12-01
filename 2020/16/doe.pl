#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/ any all /;

my %fields;
my @ticket;
my @otickets;

my $state = '1';
while (my $line = <>) {
	chomp $line;
	next unless $line;
	if ($line =~ /^your ticket/) {
		$state = 2;
	}
	elsif ($line =~ /^nearby tickets/) {
		$state = 3;
	}
	elsif ($state==1) {
		my ($f,$r) = split(/: /, $line) or die;
		my @allowed;
		foreach my $rule (split(/ or /, $r)) {
			my ($min,$max) = split(/-/, $rule) or die;
			push @allowed, [$min,$max];
		}
		$fields{$f} = \@allowed;
	}
	elsif ($state==2) {
		@ticket = split(/,/, $line);
	}
	elsif ($state==3) {
		my @theticket = split(/,/, $line);
		push @otickets, \@theticket;
	}
}

my @allrules;
foreach (values %fields) { foreach my $r (@$_) { push @allrules, $r } };

sub valid_field_all
{
	my $field = shift;
	return valid_field($field,\@allrules)
	#return any { $field >= $$_[0] and $field <= $$_[1] } @allrules;
}

sub valid_field
{
	my $val   = shift;
	my $rules = shift or die;
	return any { $val >= $$_[0] and $val <= $$_[1] } @$rules;
}


my $errorrate = 0;
my @validtickets;
foreach my $t (@otickets) {
	my $valid = 1;
	foreach my $field (@$t) {
		if (not valid_field_all($field)) {
			$errorrate+=$field;
			#print "Field $field is invalid\n";
			$valid = 0;
		}
	}
	push(@validtickets, $t) if ($valid==1);
}

print "Total errorrate is $errorrate\n";
printf "Valid tickets: %d\n", scalar @validtickets;

my @columns;
foreach my $t (@validtickets) {
	for (my $i=0; $i<@$t; $i++) {
		push @{$columns[$i]}, $$t[$i];
	}
}

my %possible;
for (my $i=0; $i<@columns; $i++) {
	foreach my $f (sort keys %fields) {
		my @rules = @{$fields{$f}};
		if (all { valid_field($_,\@rules) } @{$columns[$i]}) {
			push @{$possible{$f}}, $i;
		}
	}
}

my %matches;
while (%possible) {
	while (my ($key, $value) = each(%possible)) {
		printf "Possibilities for $key are: %s\n", join(",",@$value);
		if (@$value==1) {
			my $theval = $$value[0];
			$matches{$key} = $theval;

			# removed matched values from other possibilitite
			delete $possible{$key};
			foreach my $k (keys %possible) {
				my @newvals = grep { $theval != $_ } @{$possible{$k}};
				$possible{$k} = \@newvals;
			}
		}
	}
}

print Dumper \%matches;

my $result = 1;
print "My ticket:\n";
while (my ($k,$v) = each(%matches)) {
	printf "  %s: %d\n", $k, $ticket[$v];
	$result *= $ticket[$v]  if  $k =~ m/^departure/;
}
print "Result = $result\n";
