#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/ max min /;
use List::MoreUtils qw/ firstidx /;

my $min = 1;
my $max;

sub move {
	my $movenum = shift;
	my $current = shift or die;
	my $cups = shift or die;

	my $num = scalar(keys %$cups);

	print "-- move $movenum --\n";
	#printf "cups: (%d) %s\n", $cups[0], join(" ",@cups[1..$#cups]);
	{
		#imy @cupslist = llist($cups,$current);
		#printf "cups: (%d) %s\n", shift @cupslist, join(" ",@cupslist);
		printf "cups: (%d)\n", $current->{"num"};
	}

	my $pickedup = $current->{"next"};
	my $newnext = $pickedup->{"next"}->{"next"}->{"next"};
	$current->{"next"} = $newnext;
	$newnext->{"prev"} = $current;
	$pickedup->{"prev"} = undef;
	$pickedup->{"next"}->{"next"}->{"next"} = undef;

	printf "pick up: %d %d %d\n",
		$pickedup->{num}, $pickedup->{"next"}->{"num"}, $pickedup->{"next"}->{"next"}->{"num"};
	if (0) {
		my @cupslist = llist($cups,$current);
		printf "after pickup (%d) %s\n", shift @cupslist, join(" ",@cupslist);
	}

	my $dest = $current->{"num"};
	while (1) {
		$dest+=$max if (--$dest<$min);
		last if (
			    $dest != $pickedup->{"num"}
			and $dest != $pickedup->{"next"}->{"num"}
			and $dest != $pickedup->{"next"}->{"next"}->{"num"}
		);
	}
	print "destination: $dest\n";

	my $destcup = $cups->{$dest};
	$pickedup->{"prev"} = $destcup;
	$pickedup->{"next"}->{"next"}->{"next"} = $destcup->{"next"};
	$destcup->{"next"}->{"prev"} = $pickedup->{"next"}->{"next"};
	$destcup->{"next"} = $pickedup;

	if (0) {
		my @cupslist = llist($cups,$current);
		printf "after insert (%d) %s\n", shift @cupslist, join(" ",@cupslist);
	}

	print "\n";

	return $current->{"next"};
}

sub make_llist {
	my @input = @_;

	my %llist = map { $_ => { "num" => $_, "prev" => undef, "next" => undef } } @input;
	for (my $i=0; $i<@input; $i++) {
		my $key  = $input[$i];
		my $prev = ($i==0       ? $llist{ $input[-1] } : $llist{ $input[$i-1] } );
		my $next = ($i==$#input ? $llist{ $input[ 0] } : $llist{ $input[$i+1] } );

		$llist{$key}->{"prev"} = $prev;
		$llist{$key}->{"next"} = $next;
	}

	#$Data::Dumper::Sortkeys = 1;
	#print Dumper \%llist;

	return %llist;
}

sub llist {
	my $llist = shift or die;
	my $start = shift || $llist->{(keys %$llist)[0]};

	my $item = $start;
	my %seen;
	my @result;
	while (not exists $seen{$item->{"num"}}) {
		push @result, $item->{"num"};
		$seen{$item->{"num"}} = 1;
		$item = $item->{"next"};
	}
	return @result;
}


#my $input = "389125467";
my $input = "487912365";
my @numbers = split(//,$input);
for (my $i=max(@numbers)+1; $i<=1000000; $i++) {
	push @numbers, $i;
}
die("too many cups") unless @numbers==1000000;
$max = max @numbers;

my %cups = make_llist(@numbers);
my $current = $cups{ $numbers[0] };

for (my $i=1; $i<=10000000; $i++) {
	$current = move($i,$current,\%cups);
}
my @cupslist = llist(\%cups);
printf "final %d %d %d\n",
	$cups{1}->{num}, $cups{1}->{"next"}->{"num"}, $cups{1}->{"next"}->{"next"}->{"num"};
printf "Result: %d\n", $cups{1}->{"next"}->{"num"} * $cups{1}->{"next"}->{"next"}->{"num"};

exit;
__DATA__

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
