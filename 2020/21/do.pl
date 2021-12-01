#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use List::MoreUtils;

my %ingredients;
my %allergens;
foreach (<>) {
	chomp;
	tr/)//d;
	my ($i,$a) = split(/\(contains /);
	my @is = split(/ /,$i);
	my @as = split(/, /,$a);

	foreach my $i (@is) {
		push @{$ingredients{$i}}, [@as];
	}
	foreach my $a (@as) {
		push @{$allergens{$a}}, [@is];
	}
}

print "%ingredients:\n";
print Dumper \%ingredients;
print "%allergens:\n";
print Dumper \%allergens;
#

# intersect, but with array of arrays
sub intersect {
	my %count;
	foreach my $a (@_) {
		$count{$_}++ for @{$a};
	}
	my @common = grep { $count{$_}==@_ } keys %count;
	return @common;
}

my %good_ingredients = map {$_=>1} keys %ingredients;
foreach my $a (keys %allergens) {
	my @bad = intersect(@{$allergens{$a}});
	foreach my $b (@bad) {
		delete $good_ingredients{$b};
	}
}
print "These can't be an allergen\n";
print Dumper \%good_ingredients;
# now count
my $count=0;
foreach my $i (keys %good_ingredients) {
	$count += scalar @{$ingredients{$i}};
}
print "There are $count good ingredients\n";

my %certain_allergens;
my %certain_ingredients;
for (my $i=0; $i<100; $i++) {
	while (my ($a,$i) = each %allergens) {
		my @solution = intersect(@{$i});
		@solution = grep { not exists $certain_ingredients{$_} } @solution;

		if (@solution==1) {
			$certain_allergens{$a} = $solution[0];
			$certain_ingredients{$solution[0]} = $a;
		}
		printf "%s can be in %s\n", $a, join(",",@solution);
	}
	print "\n";

	last if (scalar(%certain_ingredients)==scalar(%allergens));
}

print Dumper \%certain_allergens;
foreach $a (sort keys %certain_allergens) {
	print $certain_allergens{$a}, ","
}
print "\n";

# find all occurences in ingredients that are not
