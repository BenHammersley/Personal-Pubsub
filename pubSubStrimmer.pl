#!usr/bin/perl -w
#
### Pub Sub Strimmer
### Cleans the pubSub subcriber list. Removes entries older than 25 hours.
### Designed to be run by cron every hour.
### Version 1.0 13:04 13:March:2002
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
### Pub Sub Listener comes with two other scripts. PubSubNotifier and PubSubStrimmer,
### It's pretty important you have all three.
###
### Try http://hacks.benhammersley.com/blogging/pubsub/
###

# --------- User Changable Variables Below ---------------------------------------------

my $subscriberlistpath	= "notifyServer.txt";

# --------------------------------------------------------------------------------------




use strict;

# Work out the time right now

my $timenow = time();

# Work out the time 25 hours ago (1 hour = 3600 seconds, so 25 hours = 90000 seconds)

my $oldestpossibletime = $timenow - 90000;

# Open the subscriber list created by pubSubListener and stick it in an array, in reverse order.

open (SUBSCRIBERLIST, "<$subscriberlistpath");
my @lines = reverse <SUBSCRIBERLIST>;
close SUBSCRIBERLIST;

# Clear the subscriber list

my $file = "notifyServer.txt";
unlink ($file) or die "Can't delete the data file\n";

# Go through each line, splitting it back into the right variables.
my $line = "";
foreach $line (@lines) {
			my ($ip, $parameterName, $port, $path, $protocol, $rssUrl, $time) = split (/,/, "$line");	

			# If the time the notification request was made ($time) is later than 25 hours ago
			# ($oldestpossibletime) then stick that line back into the data file.
		

			if ($time > $oldestpossibletime)
				{
				open (NEWSUBSCRIBERLIST, ">>$subscriberlistpath");
				print NEWSUBSCRIBERLIST "$line";
				close NEWSUBSCRIBERLIST;
				};
			};

# That's it.
