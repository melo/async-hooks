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

=head1 NAME

Async::Hooks::Ctl - Hook control object


=head1 VERSION

Version 0.01


=head1 SYNOPSIS

    # inside a callback
    
    sub my_callback {
      my $ctl = shift;     # This is the Async::Hooks::Ctl object
      my $args = shift;    # Arguments for the hook
      
      $args = $ctl->args;  # Args are also available with the args() method
      
      return $ctl->done;          # no other callbacks are called
                           # ... or ...
      return $ctl->decline;       # call next callback
    }


=head1 DESCRIPTION

A C<Async::Hooks::Ctl> object controls the sequence of invocation of
callbacks.

Each callback receives two parameters: a C<Async::Hooks::Ctl> object,
and a arrayref with the hook arguments.

Each callback must call one of the sequence control methods before
returning. Usually you just write:

    return $ctl->done();
    # ... or ...
    return $ctl->decline();

If you know what you are doing, you can do this:

    $ctl->decline();
    # do other stuff here
    return;

But there are no guarantees that your code after the control method call
will be run at the end of the callback sequence.

The important rule is that you must one and only one of the control
methods per callback.

The object provides two methods that control the invocation sequence,
C<decline()> and C<done()>. The C<done()> method will stop the sequence,
and no other callback will be called. The C<decline()> method will call
the next callback in the sequence.

A cleanup callback can also be defined, and it will be called at the end
of all callbacks, or imediatly after C<done()>.

The C<decline()> method can also be called as C<declined()> or
C<next()>. The C<done()> method can also be called as C<stop()>.

=head1 METHODS

=over

=item CLASS->new($hooks, $args, $cleanup)

The C<new()> constructor returns a C<Async::Hooks::Ctl> object. All
parameters are optional.

=over

=item * $hooks

An arrayref with all the callbacks to call.

=item * $args

An arrayref with all the hook arguments.

=item * $cleanup

A coderef with the cleanup callback to use.

=back

=item $ctl->args()

Returns the hook arguments.


=item $ctl->decline()

Calls the next callback in the hook sequence.

If there are no callbacks remaining, the cleanup callback is called if
it exists.


=item $ctl->declined()

An alias to C<< $ctl->decline() >>.


=item $ctl->next()

An alias to C<< $ctl->decline() >>.


=item $ctl->done()

Stops the callback sequence. No other callbacks in the sequence will
be called.

The cleanup callback is called if it exists.


=item $ctl->stop()

An alias to C<< $ctl->done() >>.


=back


=head1 AUTHOR

Pedro Melo, C<< <melo at cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Pedro Melo, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

