use Test::More tests => 8;

use strict;
use warnings;
use POE;
use_ok('POE::Component::Client::Pastebot');

my $pastebot = 'http://sial.org/pbot';
#my $pastebot = 'http://erxz.com/pb/';

POE::Session->create(
	package_states => [
	  'main' => [ qw(_start _stop _child _time_out _got_paste _got_fetch) ],
	],
	options => { trace => 0 },
);

$poe_kernel->run();
exit 0;

sub _start {
  my $kernel = $_[KERNEL];
  my $pbobj = POE::Component::Client::Pastebot->spawn( options => { trace => 0 }, debug => 1 );
  isa_ok( $pbobj, 'POE::Component::Client::Pastebot' );
  pass('started');
  $kernel->delay( '_time_out' => 60 );
  undef;
}

sub _stop {
  pass('stopped');
}

sub _time_out {
  die;
}

sub _child {
  my ($kernel,$what,$who) = @_[KERNEL,ARG0,ARG1];
  if ( $what eq 'create' ) {
	$kernel->post( $who => 'paste' => { event => '_got_paste', paste => 'Moo', url => $pastebot } );
	pass('created');
	return;
  }
  if ( $what eq 'lose' ) {
	pass('lost');
	$kernel->delay( '_time_out' );
	return;
  }
  undef;
}

sub _got_paste {
  my ($kernel,$hashref) = @_[KERNEL,ARG0];
  if ( $hashref->{pastelink} ) {
	pass('pastelink');
	$kernel->post( $_[SENDER], 'fetch', { event => '_got_fetch', url => $hashref->{pastelink} } );
  }
  else {
	warn $hashref->{error};
  	$kernel->post( $_[SENDER], 'shutdown' );
  }
  undef;
}

sub _got_fetch {
  my ($kernel,$hashref) = @_[KERNEL,ARG0];
  ok( $hashref->{content}, 'fetched' );
  warn $hashref->{error} unless $hashref->{content};
  $kernel->post( $_[SENDER], 'shutdown' );
  undef;
}
