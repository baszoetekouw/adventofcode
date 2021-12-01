#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw{ min max };
use Data::Dumper;

# calc binery number
sub calcbin($$)
{
	my ($str,$hi) = @_;

	my $num = 0;
	foreach my $c (split(//,$str)) {
		$num = ($num<<1) + ($c eq $hi);
	}
	return $num;
}

my @bps;
foreach (<>) {
	chomp;
	push @bps, $_;
}

my @seats;
foreach my $bp (@bps)
{
	my $row = substr($bp,0,7);
	my $col = substr($bp,7,3);

	my $rowid = calcbin($row,'B');
	my $colid = calcbin($col,'R');

	push @seats, { "row"=>$rowid, "col"=>$colid }
}

my %seatids = map { $_->{"row"}*8 + $_->{"col"} => 1 } values @seats;
my $min  = min(keys %seatids);
my $max  = max(keys %seatids);
print "First seat: $min\n";
print "Last seat: $max\n";

for (my $i=$min+1; $i<$max; $i++) {
	if ( exists($seatids{$i-1}) and exists($seatids{$i+1}) and not exists($seatids{$i}) ) {
		print "My seat is $i\n";
	}
}

