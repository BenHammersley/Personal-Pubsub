#!usr/bin/perl -w
use strict;
use HTTP::Daemon;
use Frontier::RPC2;
use HTTP::Date;

###
### Pub Sub Listener
### Listens for xml-rpc pubsub requests, writes the necessary to a data file.
###
### Version 1.0 12:28 19:March:2002
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
### Pub Sub Listener comes with two other scripts. PubSubNotifier and PubSubStrimmer,
### It's pretty important you have all three.
###
### Try http://hacks.benhammersley.com/blogging/pubsub/
###

# ------USER CHANGABLE VARIABLES HERE -------

my $listeningport = "8888";

# -------------------------------------------


# -----NON-CHANGABLE VARIABLES ARE SETUP HERE
my $methods 	= {'test' 		=> \&test,
		   'echotest'		=> \&echotest,
		   'pleaseNotify'	=> \&pleaseNotify
		  };

our $host = "";
#--------------------------------------------




# --------------- Start the server up ------------------------

my $listen_socket = HTTP::Daemon->new(	LocalPort => $listeningport,
					Listen    => 20,
					Proto     => 'tcp',
					Reuse     => 1
					);

die "Can't create a listening socket: $@" unless $listen_socket;

# ------------------------------------------------





# ------------- Handle the connection ----------------------

while (my $connection = $listen_socket->accept) {
	$host = $connection->peerhost;
    	interact($connection);
	$connection->close;
  	}

# ----------------------------------------------------------


# ------------- The Interact subroutine, as called when a peer connects
sub interact {
	my $sock = shift;
	my $req;
	eval {
		$req = $sock->get_request;
		};

	# Check to see if the contact is both xml and to the right path.
	
	if( $req->header('Content-Type') eq 'text/xml'&& $req->url->path eq '/RPC2') 
		{
		my $coder     = Frontier::RPC2->new('encoding' => 'ISO-8859-1');
		my $hash      = $coder->decode($req->content);
		my $res_xml   = $coder->serve($req->content,$methods);
		if( $main::Fork ){
				my $pid = fork();
				unless( defined $pid ){
 						#  check this response
						my $res = HTTP::Response->new(500,'Internal Server Error');
						$sock->send_status_line();
						$sock->send_response($res);
						}
				if( $pid == 0 ){
				$sock->close;
				$main::Fork->();
				exit;
				}
				
				$main::Fork = undef;
				}

		my $conn_host = gethostbyaddr($sock->peeraddr,AF_INET) || $sock->peerhost;
    
		my $res = HTTP::Response->new(200,'OK');
		$res->header(
				date 		=> time2str(),
				Server		=> 'PubSubServer',
				Content_Type	=> 'text/xml',
				);	
		
		$res->content($res_xml);
		$sock->send_response($res);
 
# ---------------------------------------------------------------------




#
#
#
# ------------------- Define the method subroutines
#
#
#


# ---- the TEST method-----
# Takes no argument, just returns a message


sub test	{
	return "The pubsub server seems to be running";
		};

# ---------------



# ---- the ECHO TEST method-----
# Takes one argument, and returns it

sub echotest 	{
	my ($echotest) = @_;
	return "Pubsub server: You said $echotest";
		};

#---------------------





# ---- pleaseNotify -----
# The main method - see the pod, read on for details.

sub pleaseNotify	{
	# Take the input and split it into five parameters:
	#
	# $parameterName - the name of the procedure that the cloud should call to notify the workstation of changes, 
	# $port - the TCP port the workstation is listening on, 
	# $path - the path to its responder, 
	# $protocol - a string indicating which protocol to use (xml-rpc or soap, case-sensitive), 
	# $rssUrl - and a list of urls of RSS files to be watched. 
			
	my ($parameterName, $port, $path, $protocol, $rssUrl) = @_;

	# Work out the time, in Unix-Time-Since-Epoch.

	my $time = time();
	
	# Append the variables to the datafile, comma seperated, then add new-line.
	
	open (DATA, ">>notifyServer.txt");
	print DATA "$host,$parameterName,$port,$path,$protocol,$rssUrl,$time\n";
	close DATA;
		
	# Return true value to user as per spec.
		};
# ----------------

};
};


