#!usr/bin/perl -w
use strict;
use Frontier::Client;

###
### Pub Sub Notifier
### Informs weblogs.com and the pub-sub subscribed that the rss has changed
###
### Version 1.0 13:46 19:March:2002
###
### Author: Ben Hammersley, ben@benhammersley.com
###
### Big thanks to:
### Ken MacLeod for Frontier::* and much advice. Joe Johnston for snippets of server code,
### Noah Grey for Greymatter, Dave Winer for xml-rpc and the cloud idea,
### and all the other Perl hackers, Linux geeks and madarse blogger types.
###
### This is free software. Give it away. Share the love. Tell me if you make good changes.
### Look for the latest version at http://hacks.benhammersley.com/blogging/pubsub/
###
### pubSubNotifier comes with two other scripts. pubSubListener and pubSubStrimmer,
### It's pretty important you have all three.
###
### Try http://hacks.benhammersley.com/blogging/pubsub/
###


# --------- User Changable Variables Below ---------------------------------------------

my $blogtitle 		= "benhammersley.com";
my $blogurl 		= "http://www.benhammersley.com";
my $rssUrl 		= "http://www.benhammersley.com/pubsub.xml";
my $weblogcomserver 	= "http://rpc.weblogs.com/RPC2";
my $subscriberlistpath	= "notifyServer.txt";

# --------------------------------------------------------------------------------------

# Ping Weblogs.com
# Cut here if you don't want to. ------------------------------------------------------------------------------------
my $pingclient = Frontier::Client->new(
        			url             => $weblogcomserver,
        			use_objects     => 0,
        			debug           => 0
				);

my $response = $pingclient -> call ('weblogUpdates.ping', $blogtitle, $blogurl);


# -------------------------------------------------------------------------------------------------------------------

# Now move onto the pub sub notifications

# Open the subscriber list created by pubSubListener and stick it in an array, in reverse order for fun.

open (SUBSCRIBERLIST, "<$subscriberlistpath");
my @lines = reverse <SUBSCRIBERLIST>;

# Go through each line, splitting it back into the right variables.
my $line = "";
foreach $line (@lines) {
			my ($ip, $parameterName, $port, $path, $protocol, $xrssUrl, $time) = split (/,/, "$line");	

			# Then open a client

			my $client = Frontier::Client->new (url		=> "http://$ip:$port$path",
							    debug 	=> 1,
								);
			# Then call the remote procedure with the rss url, as per the spec
			$client->call($parameterName, $rssUrl);

	   	
	      		};

# That's it.
