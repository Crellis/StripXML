#! /usr/bin/perl
#
#  Filename: stripXML.pl
#  Purpose: To scan through elements of an XML sitemap and grab elements with certain property
#           value pairs and remove the entire containing element to get a full list of URLs
#           for a site migration tool
#
#  Author:  Craig Ellis
#
use strict;

my $fileToStrip = "sitemap.xml"; #filename
my $outputFile = "output.xml"; #output file
my $failureFile = "failureFile.xml"; #stipped xml

my $container = "<lastmod>"; #open tag
my $containerCloser = "</lastmod>"; #close tag

my $fileToRead = checkfile($fileToStrip);
my $fileToWrite = checkOutputFile($outputFile);
my $failFile = checkOutputFile($failureFile);

my @holderVar;  #just some empty space to hold strings
my $starter = 0;
my $lineCatcher = 0;
my $i = 0;
my $x = 0;

#read the input file
while ( <$fileToRead> )
{
	my $thisLine =  $_;
  chomp($thisLine);
  if ( $thisLine =~ m/$container/ ) {
    $starter = 1; #got a start (tag opened)
  }
  if ( $thisLine =~ m/$containerCloser/) {
    $starter = 2; #tag closed
  }
  
  #write the element into memory
  if ( $starter == 0 ) {
    $thisLine .= "\n";
    print $fileToWrite $thisLine;
  }
  else {
    $holderVar[$i] = $thisLine . "\n";
    $i++;
  }
  #does the element contain a 'hit' code?  if so mark $holderVar to dump it
  if ( $thisLine =~ m/$searcher/ ) {
    $lineCatcher = 1;
    # print "got a hit\n";
  }
  if ( $starter == 2 && $lineCatcher == 1) {
    #put this dog down
    my $endValue = scalar(@holderVar);
    for ($x=0;$x<$endValue;$x++) {
      # uncomment to debug:
      # my $tagWriter = "<!--- " . $holderVar[$x] . " --->";
      # print $fileToWrite $tagWriter;
      print $failFile $holderVar[$x];
      $holderVar[$x] = "";
    }
    $lineCatcher = 0;
    $i=0;
    $starter = 0;
  }
  elsif ( $starter == 2 && $lineCatcher == 0) {
    #legit doggie, let him roam
    my $endValue = scalar(@holderVar);
    for ($x=0;$x<$endValue;$x++) {
      print $fileToWrite $holderVar[$x];
      $holderVar[$x] = "";
    }
    $i=0;
    $starter = 0;
  }
}


#subroutines
sub checkfile {
	#checks the input file to make sure it's valid and can be opened
	my $file = $_[0];
	if (length($file) == 0) {print "No input file specified.\n"; return 0;}
	my $theFile;
	if (! open($theFile, $file)) {
		logError("failed to open file '" . $file . "'.  Check to see if it exists.");
		return 0;
	}
	else {
		return $theFile;
	}

}
sub checkOutputFile {
	#checks the output files to make sure they're valid
	my $file = $_[0];
	my $openFile;
  my $status = (stat($file))[7];
  if (! $status) { $status = 0;}
	if ( $status != 0) {
		open($openFile, ">>" . $file) or logError("Couldn't open output file for appending " . $file);
		return $openFile;
	}
	else {
		open($openFile, ">" . $file) or logError("Couldn't create new output file " . $file);
		return $openFile;
	}
}
sub logError {
  print $_[0];
}