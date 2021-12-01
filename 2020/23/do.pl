#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/ max min /;
use List::MoreUtils qw/ firstidx /;

sub move {
	my $movenum = shift;
	my @cups = @_ or die;

	my $max = max @cups;
	my $min = min @cups;

	print "-- move $movenum --\n";
	#printf "cups: (%d) %s\n", $cups[0], join(" ",@cups[1..$#cups]);
	printf "cups: (%d)\n", $cups[0];

	my @pickedup = @cups[1..3];
	$cups[$_] = $cups[$_+3] for 1..($#cups-3);
	$#cups -= 3;

	printf "pick up: %s\n", join(" ",@pickedup);

	my $dest = $cups[0];
	while (1) {
		$dest+=$max if (--$dest<$min);
		last if ($pickedup[0]!=$dest and $pickedup[1]!=$dest and $pickedup[2]!=$dest);
	}
	print "destination: $dest\n";

	my $idx;
	for ($idx=0; $cups[$idx]!=$dest and $idx<@cups; $idx++) {};
	splice(@cups, $idx+1, 0, @pickedup);

	print "\n";

	push @cups, (shift @cups);

	return @cups;
}


my $input = "389125467";
#my $input = "487912365";
my @cups = split(//,$input);

for (my $i=1; $i<=100; $i++) {
	@cups = move($i,@cups);
}
printf "final (%d) %s\n", $cups[0], join(" ",@cups[1..$#cups]);



@cups = split(//,$input);
for (my $i=max(@cups)+1; $i<=1000000; $i++) {
	push @cups, $i;
}
die("too many cups") unless @cups==1000000;

for (my $i=1; $i<=100; $i++) {
	@cups = move($i,@cups);
}
printf "final (%d)\n", $cups[0];
my $idx1 = firstidx { $_==1 } @cups;
print "Index for cup 1 is $idx1\n";
printf "Index at %d is %d\n", $idx1+1, $cups[$idx1+1];
printf "Index at %d is %d\n", $idx1+2, $cups[$idx1+2];
