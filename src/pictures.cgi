#!/usr/bin/env perl

use strict;
use warnings;
my $postdat=<STDIN>;
if($postdat =~ /piclist/) {
	print "content-type: text\n\n";
	my $fail=0;
	opendir my $dh, '.' or die "FAILED";
	my @files=grep /\.(jpg|png|svg|jpeg)$/i, readdir $dh;
	closedir $dh;
	print "{\"main\" : [";
	for(my $i=0;$i<(@files-1);$i++) {
		my $fname=$files[$i];
		print "{ \"tnail\" : \"${fname}_tnail\", \"imgfile\" : \"" . $fname . "\" },";
		unless(-e "${fname}_tnail") {
				$fail=system("convert -thumbnail 100 \"$fname\" \"${fname}_tnail\"") 
		}
	}
	if(@files > 0) {
		my $fname=$files[@files-1];
		print "{ \"tnail\" : \"${fname}_tnail\", \"imgfile\" : \"" . $fname . "\" }";
		unless(-e "${fname}_tnail") {
				$fail=system("convert -thumbnail 100 \"$fname\" \"${fname}_tnail\"") 
		}
	}
	print "], \"fail\" : \"$fail\" }";
	exit 1;
}

print "content-type:text/html\n\n";
print << 'HERE'
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"0>

	<title>Background Picture</title>
	<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
	<script type="text/javascript" charset="utf-8">
		var xo=new XMLHttpRequest;
		try {
			xo.open('POST', document.URL, false);
			xo.setRequestHeader('content-type', 'application/x-www-form-urlencoded');
			xo.send('piclist=junk');
			if(xo.status != 200) throw("fail");
			var response=JSON.parse(xo.responseText);
			if(response.fail != "0") throw('Unable to create thumbnail images, please ensure imagemagick is installed and "convert" is in your path, furthermore ensure that the user running the cgi script has write permissions to the directory containing the images');
			var pics=response.main;
			$(document).ready(function() {
				for(i=0;i<pics.length;i++)
					$('#main').append('<img class="thumbnail" src="'+pics[i].tnail+'"/>');
				$('#mpic').hide();
				$('#mpic').click(function() {
					$(this).hide();
				});
				$('.thumbnail').click(function() {
					var imgname;
					for(i=0;i<pics.length;i++) 
						if(pics[i].tnail == $(this).attr('src')) imgname=pics[i].imgfile;
					if(imgname.length == 0)
						alert("Image not found");
					else {
						$('#mpic').slideDown();
						$('#mpic  img').attr('src', imgname);
					}
				});
			}); 
		
		} catch(e) {
			alert(e);
		}
	</script>
	<style type="text/css" media="screen">
		#mpic {
			z-index:998;
			position:absolute;
			top:0;
			left:0;
			height:10000px;
			width:100%;
			background:black;
			opacity:1;
		}
		#mpic img{
			height:700px;
		}

		#main {
			width:700px;
			margin-left:auto;
			margin-right:auto;
			border:1px solid grey;
		}
		.thumbnail {
			width:100px;
			margin:10px;
		}
	</style>
	
</head>
<body>
	<div id="main">
	</div>
	<div id="mpic">
	<center>
		<img/>
	</center>
	</div>
</body>
</html>
HERE
