#!/usr/bin/perl
use warnings;
use strict;
use Reddit::Client;
use Try::Tiny;
use Time::Piece;
use Getopt::Long;

use FindBin;
use lib $FindBin::Bin;
use util;


my $bin=`dirname "$0"`;
$bin =~ s/\R//g;
$bin=`readlink -f $bin`;
$bin =~ s/\R//g;

sub usage {
	my $where=$_[0];
	print "======"
		. "\n" . "$where"
		. "\n" . "======"
		. "\n" . "madlibbot.pl"
		. "\n\t" . "-madlib S : the file containing the madlib data"
		. "\n\t" . "-start_comment S : the id of the comment to start the madlib thread from"
		. "\n\t\t" . "Example: t3_15bfi0"
		. "\n\t\t" . "type prefixes"
		. "\n\t\t" . "t1_	Comment"
		. "\n\t\t" . "t2_	Account"
		. "\n\t\t" . "t3_	Link"
		. "\n\t\t" . "t4_	Message"
		. "\n\t\t" . "t5_	Subreddit"
		. "\n\t\t" . "t6_	Award"
		. "\n\t\t" . "t8_	PromoCampaign"
		. "\n\t" . "-state_file S : the file to get the state from (defaults to <dir of script>/state.csv)"
		. "\n\t" . "-config S : file that contains the username and password of the reddit account (defaults to <dir of script>/config)"
		. "\n\t" . "-session S : file that the session information (defaults to <dir of script>/session.json)"
		. "\n";
	die;
}

###################################
# parsing arguments
###################################
my $madlib;
my $configLoc="$bin/config";
my $start;
my $state="$bin/state.csv";
my $session="$bin/session.json";
my $help=0;
GetOptions (
	"madlib=s" => \$madlib,
	"start_comment=s" => \$start,
	"state_file=s" => \$state,
	"config=s" => \$configLoc,
	"session=s" => \$session,
	"help" => \$help
) or usage("Error in command line arguments");
if($help){
	usage("-help flag provided");
}
util::check("start_comment", $start, \&usage);
util::check("madlib", $madlib, \&usage);


###############################################
# Login
###############################################
if(not -e $configLoc) {
	usage("Was expecting the config file at $configLoc but was not found");
}
my $reddit = util::login($configLoc, $session);


###############################################
#Load the madlib file
###############################################
open my $fhMadlib, "<", $madlib or die $!;
my @blankTypes=();
my @text=();
my $line=<$fhMadlib>;
$line =~ s/\R//g;
while(not $line eq "=========="){
	push(@blankTypes, $line);
	$line=<$fhMadlib>;
	$line =~ s/\R//g;
}

$line=<$fhMadlib>;
$line =~ s/\R//g;
while(not eof($fhMadlib)){
	push(@text, $line);
	$line=<$fhMadlib>;
	$line =~ s/\R//g;
}
close($fhMadlib);

print "Blanks:\n";
for(my $i = 0; $i<= $#blankTypes;$i++){
	my $idx=$i+1;
	print "$idx: $blankTypes[$i]\n";
}
print "Text:\n";
for(my $i = 0; $i<= $#text;$i++){
	my $idx=$i+1;
	print "$idx: $text[$i]\n";
}

my $blank_num=1;
my $comment_id = $reddit->submit_comment(
	parent_id => $start,
	text => "Hello, let's play some madlib. If you don't know what madlib is, visit [this link](https://en.wikipedia.org/wiki/Mad_Libs)."
	. "	" . "For blank $blank_num, reply with a $blankTypes[$blank_num -1]"
);

print "posted with comment id $comment_id\n";

sleep 30;
my $comment_info=$reddit->info(
	item_id => $comment_id
);
print "info about that comment: $comment_info\n";

sub waitForBlank{
	my %param = @_;
	my $comment_id=$param{comment_id};
}








