#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/ min max sum /;
use List::MoreUtils qw/ indexes firstval /;

$/="\n\n";
my %tiles;
foreach (<>) {
	my ($title,@lines) = split("\n");
	my ($num) = $title =~ m/^Tile (\d+):/ or die;
	$tiles{$num} = \@lines;
}

sub get_edges {
	my $tile = shift or die;
	$tile = $tiles{$tile} unless ref($tile);
	my ($left,$right);
	foreach my $line (@$tile) {
		$left  .= substr($line, 0,1);
		$right .= substr($line,-1,1);
	}
	return ($tile->[0],$left,$tile->[-1],$right);
}

# find all matching edges
my %edges;
while (my ($num,$tile) = each %tiles) {
	my @tile_edges = get_edges($tile);
	foreach my $e (@tile_edges) {
		if (exists $edges{$e}) {
			push @{$edges{$e}}, $num;
		}
		elsif (exists $edges{reverse($e)}) {
			push @{$edges{reverse($e)}}, $num;
		}
		else{
			$edges{$e} = [$num];
		}
	}
}

print Dumper \%edges;
printf "Found %d edges\n", scalar keys %edges;

# look for tiles with only 2 overlapping edges
my %nummatched;
while (my ($edge,$tiles) = each(%edges)) {
	die("edge $edge occurs too often") if (@$tiles>2);
	if (@$tiles==2) {
		$nummatched{$tiles->[0]}++;
		$nummatched{$tiles->[1]}++;
	}
}

print Dumper \%nummatched;

my $result=1;
my $count=0;
while (my ($t,$n) = each %nummatched) {
	if ($n==2) {
		$result *= $t;
		$count++;
	}
}
print "Found $count hoekjes\n";
print "Result is $result\n";

#####################

sub printtile {
	my @ptiles = @_ or die;

	if (ref($ptiles[0]) ne 'ARRAY') {
		@ptiles = [@ptiles];
	}

	foreach my $row (@ptiles) {
		foreach my $cell (@$row) {
			die("tile '$cell' doesn't exist") unless exists $tiles{$cell};
		}
	};
	my $len = @{$tiles{$ptiles[0]->[0]}};

	print "/".("-" x (11*@{$ptiles[0]}-1))."\\\n";
	foreach my $rtiles (@ptiles) {

		for (my $i=0; $i<$len; $i++) {
			my $j=0;
			foreach my $tn (@$rtiles) {
				my $line = $tiles{$tn}->[$i];
				print $j++==0 ? "|" : " ";
				print $line;
			}
			print "|\n";
		}
		print "|".(" " x (11*@{$ptiles[0]}-1))."|\n" if $rtiles!=$ptiles[-1];
	}
	print "\\".("-" x (11*@{$ptiles[0]}-1))."/\n";
}

# rotate counterclockwise
sub rotatetile {
	my $num = shift;
	die unless exists $tiles{$num};

	my @tile = @{$tiles{$num}};
	my @newtile;

	my $maxx = length($tile[0]);
	my $maxy = @tile;

	die unless $maxx==$maxy;

	for (my $x=0; $x<$maxx; $x++) {
		for (my $y=0; $y<$maxy; $y++) {
			$newtile[$maxx-$x-1] .= substr($tile[$y],$x,1);
		}
	}
	$tiles{$num} = \@newtile;
}

# flip horizontally
sub fliphtile {
	my $num = shift;
	die unless exists $tiles{$num};

	my @tile = @{$tiles{$num}};
	my @newtile;

	my $maxy = @tile;
	for (my $y=0; $y<$maxy; $y++) {
		$newtile[$y] = reverse $tile[$y];
	}
	$tiles{$num} = \@newtile;
}

# flip vertically
sub flipvtile {
	my $num = shift;
	die unless exists $tiles{$num};

	my @tile = @{$tiles{$num}};
	my @newtile;

	my $maxy = @tile;
	for (my $y=0; $y<$maxy; $y++) {
		$newtile[$maxy-$y-1] = $tile[$y];
	}
	$tiles{$num} = \@newtile;
}

if (0) {
	my $t = 1951;
	printtile($t);
	rotatetile($t);
	printtile($t);
	fliphtile($t);
	printtile($t);
	flipvtile($t);
	printtile($t);
	exit;
}

sub tilenum_by_edge {
	my $edge = shift or die;
	my $othertile = shift or die;

	my $tilenums = exists $edges{$edge} ? $edges{$edge} : $edges{reverse $edge};
	my $thistile = $tilenums->[0]==$othertile ? $tilenums->[1] : $tilenums->[0];

	return $thistile;
}


sub fix_orientation {
	my $tilenum = shift or die;
	my $edge = shift or die;
	my $side = shift or die;

	die("unimplemented") unless $side eq 'T' or $side eq 'L';

	# first find the matching edge, and whether or not it's reversed;
	my @tile_edges = get_edges($tiles{$tilenum});
	my $matching_edge = -1;
	my $reverse = 0;
	for (my $a=0; $a<4; $a++) {
		if ($tile_edges[$a] eq $edge) {
			$matching_edge = $a;
			last;
		}
	}
	if ($matching_edge<0) {
		$reverse = 1;
		for (my $a=0; $a<4; $a++) {
			if ($tile_edges[$a] eq reverse($edge)) {
				$matching_edge = $a;
				last;
			}
		}
	}
	die if $matching_edge<0;

	# note $matching_edge: 0=T, 1=L, 2=B, 3=R

	# check if we need to rotate
	if ( ($side eq 'L' and $matching_edge%2==0) or ($side eq 'T' and $matching_edge%2==1) ) {
		# rotating counterclockwise
		rotatetile($tilenum);
		if (++$matching_edge>=4) { $matching_edge-=4; };
		# 0->1 and 2-->3 rotation: edge reversed
		if ($matching_edge==1 or $matching_edge==3) { $reverse=1-$reverse; };
	}

	# after rotation, edge can be in 4 orientations
	# first check if edge is on correct side
	if (($side eq 'L' and  $matching_edge==3) or ($side eq 'T' and $reverse)) { fliphtile($tilenum); }
	if (($side eq 'T' and  $matching_edge==2) or ($side eq 'L' and $reverse)) { flipvtile($tilenum); }
}

my @grid = ([]);
my $edgelen = int(sqrt(keys %tiles)+0.5);

# find starting tile
my $topleft_tilenum = firstval { print "$_\n";  $nummatched{$_}==2 } keys %nummatched;
my @topleft_edges = get_edges($topleft_tilenum);
my @topleft_corneredge_idx = indexes { exists($edges{$_}) ? (1==@{$edges{$_}}) : (1==@{$edges{reverse $_}}) } @topleft_edges;
die(join(",",@topleft_corneredge_idx)) unless (($topleft_corneredge_idx[1]-$topleft_corneredge_idx[0])%2==1);

# fix orientation
flipvtile($topleft_tilenum) if ($topleft_corneredge_idx[0]==2 or $topleft_corneredge_idx[1]==2);
fliphtile($topleft_tilenum) if ($topleft_corneredge_idx[0]==3 or $topleft_corneredge_idx[1]==3);

$grid[0]->[0] = $topleft_tilenum;

if (1) {
	printtile($topleft_tilenum);
	@topleft_edges = get_edges($topleft_tilenum);
	@topleft_corneredge_idx = indexes { exists($edges{$_}) ? (1==@{$edges{$_}}) : (1==@{$edges{reverse $_}}) } @topleft_edges;
	printf "Topleft tile is $topleft_tilenum with corner edges %s\n", join(",",@topleft_corneredge_idx);
}


for (my $x=1; $x<$edgelen; $x++) {
	my $lefttilenum = $grid[0]->[$x-1];
	my $leftedge = (get_edges($tiles{$lefttilenum}))[3];

	my $tilenum = tilenum_by_edge($leftedge,$lefttilenum);
	$grid[0]->[$x] = $tilenum;
	print "Tile ($x,0) is $tilenum\n";
	fix_orientation($tilenum, $leftedge, 'L');
}
for (my $y=1; $y<$edgelen; $y++) {
	for (my $x=0; $x<$edgelen; $x++) {
		my $toptilenum = $grid[$y-1]->[$x];
		my $topedge = (get_edges($tiles{$toptilenum}))[2];

		my $tilenum = tilenum_by_edge($topedge,$toptilenum);
		$grid[$y]->[$x] = $tilenum;
		print "Tile ($x,$y) is $tilenum\n";
		fix_orientation($tilenum, $topedge, 'T');
	}
}

print "Grid looks like\n";
printtile(@grid);

# now create picture
my @pic;
my $tlen = length( $tiles{$grid[0]->[0]}->[0] );
foreach my $row (@grid) {
	for (my $y=1; $y<$tlen-1; $y++) {
		my $line = "";
		foreach my $cell (@$row) {
			my $tile = $tiles{$cell};
			$line .= substr($tile->[$y],1,$tlen-2);
		}
		push @pic, $line;
	}
}

print "\nImage looks like:\n";
print join("\n",@pic), "\n";

# rotate counterclockwise
sub pic_rotate {
	my @tile = @pic;
	my @newtile;

	my $maxx = length($tile[0]);
	my $maxy = @tile;

	die unless $maxx==$maxy;

	for (my $x=0; $x<$maxx; $x++) {
		for (my $y=0; $y<$maxy; $y++) {
			$newtile[$maxx-$x-1] .= substr($tile[$y],$x,1);
		}
	}
	@pic = @newtile;
}

# flip horizontally
sub pic_fliph {
	my @tile = @pic;
	my @newtile;

	my $maxy = @tile;
	for (my $y=0; $y<$maxy; $y++) {
		$newtile[$y] = reverse $tile[$y];
	}
	@pic = @newtile;
}

# flip vertically
sub pic_flipv {
	my @tile = @pic;
	my @newtile;

	my $maxy = @tile;
	for (my $y=0; $y<$maxy; $y++) {
		$newtile[$maxy-$y-1] = $tile[$y];
	}
	@pic = @newtile;
}

sub have_monsters1 {
	my $seamonster = "#(.)#(....)##(....)##(....)###(.)#(..)#(..)#(..)#(..)#(..)#";

	my $picstr = join("",@pic);
	my $havemonsters = $picstr =~ s/$seamonster/O$1O$2OO$3OO$4OOO$5O$6O$7O$8O$9O$10O/g;
	$havemonsters||=0;

	return $havemonsters
}

sub have_monsters {
	my @monster = (
		[18],
		[0,5,6,11,12,17,18,19],
		[1,4,7,10,13,16]
	);
	my $havemonsters=0;

	for (my $y=0; $y<@pic-2; $y++) {
		XPOS:
		for (my $x=0; $x<length($pic[$y])-19; $x++) {
			for (my $k=0; $k<3; $k++) {
				foreach my $relx (@{$monster[$k]}) {
					next XPOS unless substr($pic[$y+$k],$x+$relx,1) eq '#';
				}
			}
			$havemonsters++;
			for (my $k=0; $k<3; $k++) {
				foreach my $relx (@{$monster[$k]}) {
					substr($pic[$y+$k],$x+$relx,1)='O'
				}
			}
		}
	}

	return $havemonsters;
}

print "boe\n$pic[0]\nboe\n";

while (1) {
	my $num;
	$num = have_monsters();
	printf "Original: $num seamonsters\n";
	last if $num;

	pic_fliph();
	$num = have_monsters();
	printf "HFip: %d seamonsters\n", $num;
	last if $num;

	pic_flipv();
	$num = have_monsters();
	printf "VFip: %d seamonsters\n", $num;
	last if $num;

	pic_fliph();
	$num = have_monsters();
	printf "HFip: %d seamonsters\n", $num;
	last if $num;

	pic_rotate();
	$num = have_monsters();
	printf "Rotate: %d seamonsters\n", $num;
	last if $num;

	pic_fliph();
	$num = have_monsters();
	printf "HFip: %d seamonsters\n", $num;
	last if $num;

	pic_flipv();
	$num = have_monsters();
	printf "VFip: %d seamonsters\n", $num;
	last if $num;

	pic_fliph();
	$num = have_monsters();
	printf "HFip: %d seamonsters\n", $num;
	last if $num;

	die("No Monsters!\n");
}

my $seamonster = "#(.)#(....)##(....)##(....)###(.)#(..)#(..)#(..)#(..)#(..)#";
my $picstr = join("",@pic);
$picstr =~ s/$seamonster/O$1O$2OO$3OO$4OOO$5O$6O$7O$8O$9O$10O/g;

print "\n";

my $piclen = length($pic[0]);
for (my $y=0; $y<$piclen; $y++) {
	print substr($picstr,0+$y*$piclen,$piclen);
	my $roughness = substr($picstr,0+$y*$piclen,$piclen) =~ tr/#//;
	print "    $roughness\n",
}

my $roughness = $picstr =~ tr/#//;
print "Roughness is $roughness \n";
print "Length is ".length($picstr)."\n";
