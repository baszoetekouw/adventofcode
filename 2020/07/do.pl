#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::MoreUtils qw(uniq);

my %rules;
foreach (<>) {
	chomp;
	s/ ?bags?//g;
	my ($outer,$inner) = split(" contain ");
	my @inners = split(", ", $inner);
	$rules{$outer} = [];
	foreach my $i (@inners) {
		$i =~ m{(\d+) (.+?)\.?$} or next;
		push $rules{$outer}, { "num" => int($1), "color" => $2 };
	}
}

#print Dumper \%rules;

my %can_be_in;
while (my ($outer,$inners) = each(%rules)) {
	foreach my $inner (@$inners) {
		my $color = $inner->{color};
		push @{$can_be_in{$color}}, $outer;
	}
}

#print Dumper \%can_be_in;


sub traverse_can_be_in {
	my $inner = shift or die;

	my @colours;

	if (exists $can_be_in{$inner}) {
		push @colours, @{$can_be_in{$inner}};
		foreach my $outer (@{$can_be_in{$inner}}) {
			#print "Looking into $outer\n";
			push @colours, traverse_can_be_in($outer);
		}
	}

	return @colours;
}

my @can_contain_shiny_gold = uniq traverse_can_be_in("shiny gold");

#print Dumper \@can_contain_shiny_gold;
print "a shiny gold bag can be contained in ".scalar @can_contain_shiny_gold." other bags\n";

sub count_bags {
	my $outer = shift or die;

	my @inners = @{ $rules{$outer} };

	my $count = 0;

	foreach my $inner (@inners)
	{
		my $num = $$inner{num};
		my $col = $$inner{color};
		$count += $num * (1 + count_bags($col));
	}

	return $count;
}

my $total_bags = count_bags("shiny gold");
print "My gold bag must contain $total_bags bags.\n";

