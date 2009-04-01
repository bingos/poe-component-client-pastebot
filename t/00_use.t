use strict;
use Test::More tests => 1;

BEGIN {
	use_ok( 'POE::Component::Client::Pastebot' );
}

diag( "Testing POE::Component::Client::Pastebot $POE::Component::Client::Pastebot::VERSION, Perl $], $^X" );
