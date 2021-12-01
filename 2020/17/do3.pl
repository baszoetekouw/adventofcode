#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

sub printgrid($) {
	my $grid = shift or die;
	for (my $w=0; $w<@${grid}; $w++) {
		for (my $z=0; $z<@{$grid->[0]}; $z++) {
			print "w=$w, z=$z\n  ";
			for (my $y=0; $y<@{$grid->[0]->[0]}; $y++) {
				for (my $x=0; $x<@{$grid->[0]->[0]->[0]}; $x++) {
					print $grid->[$w]->[$z]->[$y]->[$x];
				}
				print "\n  ";
			}
			print "\n";
		}
	}

}



sub count_neighbours($$$$$) {
	my ($cx,$cy,$cz,$cw) = (shift,shift,shift,shift);
	my $grid = shift or die;

	my $w_num = scalar @{$grid};
	my $z_num = scalar @{$grid->[0]};
	my $y_num = scalar @{$grid->[0]->[0]};
	my $x_num = scalar @{$grid->[0]->[0]->[0]};

	my $debug = 0;
	$debug = 1 if $cx==0 and $cy==0 and $cz==0;

	my $count = 0;
	for (my $w=$cw-1; $w<=$cw+1; $w++) {
		next if $w<0 or $w>=$w_num;
		for (my $z=$cz-1; $z<=$cz+1; $z++) {
			next if $z<0 or $z>=$z_num;
			for (my $y=$cy-1; $y<=$cy+1; $y++) {
				next if $y<0 or $y>=$y_num;
				for (my $x=$cx-1; $x<=$cx+1; $x++) {
					next if $x<0 or $x>=$x_num;
					next if $w==$cw and $z==$cz and $y==$cy and $x==$cx;
					#printf(" --> ($x,$y,$z,$w)==%s\n",$grid->[$w]->[$z]->[$y]->[$x]) if $debug;
					$count++ if $grid->[$w]->[$z]->[$y]->[$x] eq '#';
				}
			}
		}
	}
	return $count;
}

sub countgrid($) {
	my $grid = shift or die;

	my $w_num = scalar @{$grid};
	my $z_num = scalar @{$grid->[0]};
	my $y_num = scalar @{$grid->[0]->[0]};
	my $x_num = scalar @{$grid->[0]->[0]->[0]};

	my $count = 0;
	for (my $w=0; $w<$w_num; $w++) {
		for (my $z=0; $z<$z_num; $z++) {
			for (my $y=0; $y<$y_num; $y++) {
				for (my $x=0; $x<$x_num; $x++) {
					$count++ if $grid->[$w]->[$z]->[$y]->[$x] eq '#';
				}
			}
		}
	}
	return $count;
}

sub step($) {
	my $grid = shift or die;

	my $w_num = scalar @{$grid};
	my $z_num = scalar @{$grid->[0]};
	my $y_num = scalar @{$grid->[0]->[0]};
	my $x_num = scalar @{$grid->[0]->[0]->[0]};

	my @newgrid;

	for (my $new_w=-1; $new_w<=$w_num; $new_w++) {
		my $old_w = ($new_w>=0 and $new_w<$w_num) ? $new_w : undef;
		for (my $new_z=-1; $new_z<=$z_num; $new_z++) {
			my $old_z = ($new_z>=0 and $new_z<$z_num) ? $new_z : undef;
			for (my $new_y=-1; $new_y<=$y_num; $new_y++) {
				my $old_y = ($new_y>=0 and $new_y<$y_num) ? $new_y : undef;
				for (my $new_x=-1; $new_x<=$x_num; $new_x++) {
					my $old_x = ($new_x>=0 and $new_x<$x_num) ? $new_x : undef;

					my $count = count_neighbours($new_x,$new_y,$new_z,$new_w,$grid);

					my $cell = '_';
					if (defined($old_w) and defined($old_z) and defined($old_y) and defined($old_x)) {
						$cell = $grid->[$old_w]->[$old_z]->[$old_y]->[$old_x];
					}

					#printf "(%+d,%+d,%+d) is %s and has %d neighbours\n", $new_x,$new_y,$new_z, $cell, $count;

					my $newcell = '.';
					if ($cell eq '#' and ($count==2 or $count==3)) {
						$newcell = '#';
					}
					elsif ($cell ne '#' and $count==3) {
						$newcell = '#';
					}
					$newgrid[$new_w+1]->[$new_z+1]->[$new_y+1]->[$new_x+1] = $newcell;
				}
			}
		}
	}

	return \@newgrid;
}

my @inital;
foreach (<>) {
	chomp;
	push @inital, [ split(//) ];
}

my $grid;
$grid->[0]->[0] = [@inital];
printgrid($grid);

for (my $i=1; $i<=6; $i++) {
	$grid = step($grid);
	my $active = countgrid($grid);
	print "\n=============\n";
	print "After step $i (active: $active):\n";
	#printgrid($grid);
}


