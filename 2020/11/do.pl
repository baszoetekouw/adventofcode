#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/ min max/;
use Clone qw/ clone /;

sub print_seats {
	my @seats = @_;
	my $occupied=0;
	for (my $r=0; $r<@seats; $r++) {
		for (my $c=0; $c<@{$seats[$r]}; $c++) {
			print $seats[$r]->[$c];
			$occupied++ if $seats[$r]->[$c] eq '#';
		}
		print "\n";
	}
	print "occupied: $occupied\n";
	print "\n";
}

my @seats;
foreach (<>) {
	chomp;
	push @seats, [split(//)];
}
my $numrows = @seats;
my $numcols = @{$seats[0]};

print "Start:\n";
print_seats(@seats);

for (my $i=0; $i<100; $i++) {
	print "============\n";
	print "Iteration $i:\n";

	my $changed = 0;
	my @oldseats = @{ clone(\@seats) };
	for (my $r=0; $r<@seats; $r++) {
		for (my $c=0; $c<$numcols; $c++) {
			next if ($seats[$r]->[$c] eq '.');

			my $occupied = 0;
			LOOP2:
			foreach my $rr (-1,0,1) {
				foreach my $rc (-1,0,1) {
					next if $rr==0 and $rc==0;
					my ($nr,$nc) = ($r+$rr,$c+$rc);
					next unless $nr>=0 and $nc>=0 and $nr<$numrows and $nc<$numcols;
					$occupied++ if $oldseats[$nr]->[$nc] eq '#';

					last LOOP2 if $occupied>=4;
				}
			}
			if ($seats[$r]->[$c] eq '#' and $occupied>=4) {
				$seats[$r]->[$c] = 'L';
				$changed++;
			}
			elsif ($seats[$r]->[$c] eq 'L'  and  $occupied==0) {
				$seats[$r]->[$c] = '#';
				$changed++;
			}
		}
	}
	print "changed: $changed\n";
	print_seats(@seats);
	last if $changed==0;
}
