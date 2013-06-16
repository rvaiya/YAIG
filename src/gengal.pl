#!/usr/bin/env perl

#Base content

open FH, "<", "base.html";
my $basehtml=join "", <FH>;
close FH;


#Begin Script

my ($thumbheight, $thumbwidth)=(100,60);
my @FE = qw/jpg png tiff gif/; #Image extensions

sub requirements {
	my @mark=`convert --version`;
	die "Could not find image magick" if (!(grep /ImageMagick/i, @mark));
}

sub gengal {
	mkdir 'tnail';
	my $dir=shift;
	$dir = $dir ? $dir : ".";

	opendir (my $dh, $dir) or die "Unable to open \"$dir\"";	
	my @images=readdir($dh);
	closedir($dh);
	@images = grep { $x=0;foreach $FE (@FE) { if ($_ =~ /${FE}$/i) { $x=1;break; } } $x; } @images;
	
	my $entries="";
	foreach (@images) {
		my $rc=system("convert -thumbnail ".$thumbheight.'x'.$thumbwidth." $_ tnail/${_}");
		if(!$rc) {
			$entries.='<div class="thumbwrapper"> <img src="'."tnail/$_".'"/> </div>';
		}
	}
	$basehtml =~ s#<!--IMAGES-->#$entries#;
	print $basehtml;
}


requirements();
gengal();
