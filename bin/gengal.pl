#!/usr/bin/env perl

#Base content

my $basehtml=sprintf(<<'HERE'
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"0>
	<title>Picture List</title>
		<style type="text/css" media="screen">
			#loading {
				position:relative;
				top:50%;
				left:50%;
				margin-left:-10px;
				margin-top:-10px;
				width:20px;
				height:20px;

				border-radius:100%;
				-webkit-border-radius:100%;
				-moz-border-radius:100%;
				-ms-border-radius:100%;
				-o-border-radius:100%;

				background: linear-gradient(270deg, black, lightgrey);
				background: -webkit-linear-gradient(270deg, black, lightgrey);
				background: -moz-linear-gradient(270deg, black, lightgrey);
				background: -ms-linear-gradient(270deg, black, lightgrey);
				background: -o-linear-gradient(270deg, black, lightgrey);

				animation: lding 1s linear 0s infinite normal;
				-webkit-animation: lding 1s linear 0s infinite normal;
				-moz-animation: lding 1s linear 0s infinite normal;
				-ms-animation: lding 1s linear 0s infinite normal;
				-o-animation: lding 1s linear 0s infinite normal;
			}

			#loading > div {
				border-radius:100%;
				-webkit-border-radius:100%;
				-moz-border-radius:100%;
				-ms-border-radius:100%;
				-o-border-radius:100%;
				top:50%;
				left:50%;
				width:16px;
				height:16px;
				background-color: rgba(0,0,0,0.8);
			}

			@keyframes lding {
				0% { transform: rotate(0deg); }
				100% { transform: rotate(360deg); }
			}

			@-o-keyframes lding {
				0% { transform: rotate(0deg); }
				100% { transform: rotate(360deg); }
			}

			@-webkit-keyframes lding {
				0% { -webkit-transform: rotate(0deg); }
				100% { -webkit-transform: rotate(360deg); }
			}


			html {
				background-color:black;
			}

			#thumblist {
				width: 80%;
				margin-left:auto;
				margin-right:auto;
			}
			

		    div.thumbwrapper {
				border-width: 1px; 
				border-style:solid;
				margin: 5px;
				width:100px;
				height:60px;
				float:left;
			}

			div.thumbwrapper:hover {
				border: 1px solid red;
			}

		    .thumbwrapper img {
				display:block;
				height:inherit;
				max-width:100%;
				margin-left: auto;
				margin-right: auto;
			}
			
			#mpic {
				position:relative;
				top: 50%;
				left: 50%;
				max-width:80%;
				max-height:80%;
				border: 10px solid white;
				border-radius: 5px;
				display:none;
			}
			
			#backmask {
				position: fixed;
				top:0%;
				width:100%;
				height:100%;
				background-color: rgba(0,0,0,0.8);
				z-index:100;
				display:none;
			}

		</style>

		<script type="text/javascript" charset="utf-8">
			
			window.onload=function() {
				var backmask=document.getElementById("backmask");
				var mpic=document.getElementById("mpic");
				var lding=document.getElementById("loading");
				var tnails=document.getElementsByClassName("thumbwrapper");

				backmask.onclick=function() { this.style.display='none'; };
					
				function displaypic(url) {
					//Init Loading
					mpic.style.display='none';
					lding.style.display='block';
					backmask.style.display='block'; //Comes first so clientHeight is accessible
						
					mpic.src=url.replace('tnail/','');
					mpic.onload=function() {
						lding.style.display='none';
						backmask.style.display='block'; 
						this.style.display='block';

						//Centering
						mpic.style.marginTop=-this.clientHeight/2 + 'px';
						mpic.style.marginLeft=-this.clientWidth/2 + 'px';
					};
				}

				for(var x=0;x<tnails.length;x++) {
					var tnail=tnails[x];
					var pic=tnail.children[0];
					tnail.onclick=function() { displaypic(this.children[0].getAttribute('src')); };
				}
			};
		</script>
</head>
<body>
	<div id="backmask">
		<div id="loading"><div></div></div>
		<img id="mpic" src=""/> 
	</div>

	<div id="thumblist">
	<!--IMAGES-->
	</div>	
</body>
</html>
HERE
);




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
