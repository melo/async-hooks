package Async::Hooks::Ctl;

use strict;
use warnings;

our $VERSION = '0.1';


# $self is a arrayref with two positions:
#   . first  is a arrayref with hooks to call;
#   . second is a arrayref with the arguments of each hook;
#   . third is the cleanup sub: always called even when done().
# 
 
sub new  { return bless [ undef, $_[1]||[], $_[2]||[], $_[3] ], $_[0] }

sub args   { return $_[0][2] }

# stop() or done() stops the chain
sub done {
  my $ctl = $_[0];
  
  @{$ctl->[1]} = ();
  
  if (my $cleanup = $ctl->[3]) {
    return $cleanup->($ctl, $ctl->[2]);
  }
  
  return;
}
  
*stop = \&done;


# decline(), declined() or next() will call the next hook in the chain
sub decline {
  my $ctl = $_[0];

  my $hook = shift @{$ctl->[1]};
  return $hook->($ctl, $ctl->[2]) if $hook;

  if (my $cleanup = $ctl->[3]) {
    return $cleanup->($ctl, $ctl->[2]);
  }
  
  return;
}
*declined = \&decline;
*next = \&declined;

1; # End of Async::Hooks::Ctl