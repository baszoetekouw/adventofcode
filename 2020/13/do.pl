#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use POSIX qw/ ceil /;
use List::Util qw / min /;

my $depart = int(<>);
$_ = <>; chomp;
my @busses = split(/,/);

my @times = grep { $_ ne 'x' } @busses;

my %bustimes;
foreach my $bus (@times) {
	my $firsttime = ceil($depart/$bus)*$bus;
	$bustimes{$firsttime} = $bus;
}

print "bus $bustimes{$_} leaves at $_\n" for keys %bustimes;
my $firsttime = min keys %bustimes;
print "Earliest bus no $bustimes{$firsttime} leaves at $firsttime, have to wait ".($firsttime-$depart)."\n";
printf "Answer is %d\n", ($firsttime-$depart)*$bustimes{$firsttime};
print "\n=====\n\n";

for (my $m=0; $m<@busses; $m++) {
	next if $busses[$m] eq 'x';
	printf "at min %2d bus %3d should depart\n", $m, $busses[$m];
}

sub doe
{
	print "\n======\n=====\n\n";

	my $a = 1;
	my $b = 7;
	my $result = 0;

	my $kgv = $a*$b;
	for (my $i=$result; $i<$kgv; $i+=$a) {
		my $diff = $b-($i%$b);
		printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
		if ($diff==0) {
			$result = $i;
			last;
		}
	}

	print "--\n";

	$a = $kgv;
	$b = 13;
	$kgv = $a*$b;
	for (my $i=$result; $i<$kgv; $i+=$a) {
		my $diff = $b-($i%$b);
		printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
		if ($diff==1) {
			$result = $i;
			last;
		}
	}

	print "--\n";

	$a = $kgv;
	$b = 59;
	$kgv = $a*$b;
	for (my $i=$result; $i<$kgv; $i+=$a) {
		my $diff = $b-($i%$b);
		printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
		if ($diff==4) {
			$result = $i;
			last;
		}
	}

	print "--\n";

	$a = $kgv;
	$b = 31;
	$kgv = $a*$b;
	for (my $i=$result; $i<$kgv; $i+=$a) {
		my $diff = $b-($i%$b);
		printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
		if ($diff==6) {
			$result = $i;
			last;
		}
	}

	print "--\n";

	$a = $kgv;
	$b = 19;
	$kgv = $a*$b;
	for (my $i=$result; $i<$kgv; $i+=$a) {
		my $diff = $b-($i%$b);
		printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
		if ($diff==7) {
			$result = $i;
			last;
		}
	}

	printf "%4d mod %2d = %2d\n", $result,  7, -$result %  7;
	printf "%4d mod %2d = %2d\n", $result, 13, -$result % 13;
	printf "%4d mod %2d = %2d\n", $result, 59, -$result % 59;
	printf "%4d mod %2d = %2d\n", $result, 31, -$result % 31;
	printf "%4d mod %2d = %2d\n", $result, 19, -$result % 19;

}
#doe;

sub reallydoe
{
	my %input = @_;
	my $kgv = 1;
	my $result = 0;

	my @times = sort {$::a<=>$::b} keys %input;
	foreach my $minute (@times)
	{
		print "-- minute=$minute, bus=$input{$minute}\n";

		my $a = $kgv;
		my $b = $input{$minute};
		$kgv = $a*$b;
		my $i;
		for ($i=$result; $i<$kgv; $i+=$a) {
			my $diff = (($b-$i)%$b);
			printf "At %2d, a(%2d) is mod %2d and b(%2d) is mod %2d; diff is %2d\n", $i, $a, $i%$a, $b, $i%$b, $diff;
			if ($diff==($minute % $b)) {
				$result = $i;
				print "$result mod $input{$minute} = ".(-$result % $input{$minute})." == $minute\n";
				last;
			}
		}
		die if $i>=$kgv;
	}

	foreach my $minute (@times) {
		#print "$result mod $input{$minute} = ".(-$result % $input{$minute})." == $minute\n";
		my $bus = $input{$minute};
		printf "At time %d + %2d bus %3d passes ", $result, $minute, $bus;
		printf "because (%d+%3d=%d) mod %3d = %d ", $result, $minute, $result+$minute, $bus, ($result+$minute) % $bus;
		print "\n";
	}
}

my %input;
for (my $i=0; $i<@busses; $i++) {
	next if $busses[$i] eq 'x';
	$input{$i} = $busses[$i];
}

reallydoe(%input);
