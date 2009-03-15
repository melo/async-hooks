package Async::Hooks::Ctl;

use strict;
use warnings;

our $VERSION = '0.1';


# $self is a arrayref with two positions:
#   . first  is a arrayref with hooks to call;
#   . second is a arrayref with the arguments of each hook.
# 
 
sub new  { return bless [ undef, $_[1]||[], $_[2]||[] ], $_[0] }

sub args   { return $_[0][2] }

# stop() or done() stops the chain
sub done { @{$_[0][1]} = () }
*stop = \&done;


# decline(), declined() or next() will call the next hook in the chain
sub decline {
  my $hook = shift @{$_[0][1]} or return;

  return $hook->($_[0], $_[0][2]);
}
*declined = \&decline;
*next = \&declined;

1; # End of Async::Hooks::Ctl