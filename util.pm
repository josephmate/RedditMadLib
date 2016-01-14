#!/usr/bin/perl
use strict;
use warnings;

use Reddit::Client;
use Try::Tiny;
use Time::Piece;
use Getopt::Long;


use Carp;

use JSON           qw//;

use LWP::UserAgent qw//;
use HTTP::Request  qw//;
use URI::Encode    qw/uri_encode/;


package util;


sub check {
  my $name = $_[0];
  my $val = $_[1];
	my $usageFcn = $_[2];

	if(not defined $val) {
		$usageFcn->("-$name missing");
	} 
}   

sub login {
  my $configLoc = $_[0];
  my $session = $_[1];

	open my $fhAccount, "<", $configLoc or die $!;
	my $username = <$fhAccount>;
	$username =~ s/\R//g;
	my $password = <$fhAccount>;
	$password =~ s/\R//g;
	close($fhAccount);

	my $reddit = Reddit::Client->new(
		session_file => $session,
		user_agent   => 'madlibbot/v0.01',
	);  

	if ( $reddit->is_logged_in ) { 
		print "already logged in\n";
	} else {
		print "logging in because session state is stale or doesn't exist\n";
		$reddit->login($username,  $password);
		$reddit->save_session();
	}   

	return $reddit;
}

sub getDirectChildren {
  my $reddit = $_[0];
  my $article_id = $_[1];
  my $parent_comment_id = $_[2];

	my $request = HTTP::Request->new();
	$request->uri("http://www.reddit.com/comments/$article_id?comment=$parent_comment_id&context=1&depth=2&sort=old");
	$request->header('Cookie', sprintf('reddit_session=%s', $reddit->{cookie}));
	$request->method('GET');
	$request->content_type('application/x-www-form-urlencoded');

	my $opt = { encode_reserved => 1 };
	my $modhash=URI::Encode::uri_encode($reddit->{modhash}, $opt);
	$request->content("modhash=$modhash&uh=$modhash");

	my $ua  = LWP::UserAgent->new(agent => 'madlibbot/v0.01', env_proxy => 1);
	my $res = $ua->request($request);
	
	print "my cookie : $reddit->{cookie}\n";

	if ($res->is_success) {
		my $json = JSON::from_json($res->content);
		return $json;
	} else {
		printf('Request error: HTTP %s\n', $res->status_line);
	}

}


1;
