#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

sub bit_pos($)
{
	my $n = shift;
	my @pos;
	my $i = 0;
	while ($n) {
		push(@pos, $i) if $n & 0x01;
		$n >>= 1;
		$i++;
	}
	return @pos;
}

sub count_bis($) {
	return scalar bit_pos(shift);
}

sub generate_bitmasks {
	my $base = shift;
	my @bitpos = bit_pos(shift);

	my @possibilities;
	# iterate over all possibilities
	for (my $i=0; $i<2**@bitpos; $i++) {
		my $mask = $base;
		# iterate over all bits
		for (my $b=0; $b<@bitpos; $b++) {
			my $bitval =  (($i>>$b) & 0x01);
			if ($bitval==1) {
				$mask |= 0x01<<$bitpos[$b];
			} else {
				$mask &= ~(0x01<<$bitpos[$b]);
			}
		}
		push @possibilities, $mask;
	}
	return @possibilities;
}


#print Dumper [bit_pos(3)];
#print Dumper [bit_pos(131)];
#print Dumper [bit_pos(65535)];
#print Dumper [generate_bitmasks(0,17)];
#exit(0);


my @cmds;
foreach (<>) {
	my ($cmd, $addr, $val) = m{^(\w+)(?:\[(\d+)\])? = (\w+)} or die;
	push @cmds, { 'cmd' => $cmd, 'addr' => $addr, 'val' => $val };
}


my $mask0;
my $mask1;
my $maskX;
my %mem1;
my %mem2;

foreach my $item (@cmds) {
	my $cmd  = $item->{cmd};
	my $addr = $item->{addr};
	my $val  = $item->{val};

	if ($cmd eq 'mask') {
		my @bits = reverse split(//,$val);
		$mask0 = $mask1 = $maskX = 0x0;
		for (my $i=0; $i<@bits; $i++) {
			if ($bits[$i] eq '0') {
				$mask0 |= 1<<$i;
			}
			elsif ($bits[$i] eq '1') {
				$mask1 |= 1<<$i;
			}
			elsif ($bits[$i] eq 'X') {
				$maskX |= 1<<$i;
			}
			else {
				die("unknown bit '$bits[$i]'\n");
			}
		}
		print "Masks:\n";
		printf "  0: %36b\n  1: %36b\n  X: %36b\n", $mask0, $mask1, $maskX;
	}
	elsif ($cmd eq 'mem') {
		$mem1{$addr} = ( ($val & $maskX) | $mask1 & (~$mask0) );
		printf "mem1[$addr] = %b (%d)\n", $mem1{$addr}, $mem1{$addr};

		my $addr2_base = $addr | $mask1 & (~$mask0);
		my @addresses = generate_bitmasks($addr2_base, $maskX);
		for my $a (@addresses) {
			$mem2{$a} = $val;
			printf "mem2[$a] = %b (%d)\n", $mem2{$a}, $mem2{$a};
		}
	}
	else {
		die("Unknown command '$cmd'\n");
	}
}

my $result1 = 0;
$result1 += $_ for (values %mem1);
print "Sum of memory1 is $result1\n";

my $result2 = 0;
$result2 += $_ for (values %mem2);
print "Sum of memory2 is $result2\n";



