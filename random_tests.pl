#!/usr/bin/perl
use warnings;
use strict;
use Reddit::Client;
use Try::Tiny;
use Time::Piece;
use Getopt::Long;
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin;
use util;


my $bin=`dirname "$0"`;
$bin =~ s/\R//g;
$bin=`readlink -f $bin`;
$bin =~ s/\R//g;


###################################
# parsing arguments
###################################
my $configLoc="$bin/config";
my $state="$bin/state.csv";
my $session="$bin/session.json";

###############################################
# Login
###############################################
if(not -e $configLoc) {
	usage("Was expecting the config file at $configLoc but was not found");
}
my $reddit = util::login($configLoc, $session);


my $article_id="40ujjz";
my $comment_id="cyx7dd2";

my %response = %{util::getDirectChildren($reddit, $article_id, $comment_id)};


print Dumper(\%response);
print "\n";
