package Async::Hooks;

use Mouse;
use Async::Hooks::Ctl;

our $VERSION = '0.01';

has registry => (
  isa => 'HashRef',
  is  => 'ro',
  default =>  sub { {} }, 
);


sub hook {
  my ($self, $hook, $cb) = @_;
  
  confess("Missing first parameter, the hook name, ") unless $hook;
  confess("Missing second parameter, the coderef callback, ")
    unless ref($cb) eq 'CODE';
  
  my $cbs = $self->{registry}{$hook} ||= [];
  push @$cbs, $cb;
  
  return;
}


sub call {
  my ($self, $hook, $args, $cleanup) = @_;
  
  confess("Missing first parameter, the hook name, ") unless $hook;
  confess("Second parameter, the arguments list, must be a arrayref, ")
    if $args && ref($args) ne 'ARRAY';
  confess("Third parameter, the cleanup callback, must be a coderef, ")
    if $cleanup && ref($cleanup) ne 'CODE';
  
  my $r = $self->{registry};
  my $cbs = exists $r->{$hook}? $r->{$hook} : [];
  
  return Async::Hooks::Ctl->new($cbs, $args, $cleanup)->next;
}


no Mouse;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Async::Hooks - Hook system with asynchronous capabilities


=head1 VERSION

Version 0.01


=head1 SYNOPSIS

    use Async::Hooks;
    
    my $nc = Async::Hooks->new;
    
    # Hook a callback on 'my_hook_name' chain
    $nc->hook('my_hook_name', sub {
      my ($ctl, $args) = @_;
      my $url = $args->[0];
      
      # Async HTTP get, calls sub when it finishes
      http_get($url, sub {
        my ($data) = @_;
        
        return $ctl->done unless defined $data;

        # You can use unused places in $args as a stash
        $args->[1] = $data;
        
        $ctl->next;
      });
    });
    
    $nc->hook('my_hook_name', sub {
      my ($ctl, $args) = @_;
      
      # example transformation
      $args->[1] =~ s/(</?)(\w+)/"$1".uc($2)/ge;
      
      $ctl->next;
    });
    
    # call hook with arguments
    $nc->call('my_hook_name', ['http://search.cpan.org/']);
    
    # call hook with arguments and cleanup
    $nc->call('my_hook_name', ['http://search.cpan.org/'], sub {
      my ($ctl, $args) = @_;
      
      if (defined $args->[1]) {
        print "Success!\n"
      }
      else {
        print "Oops, could not retrieve URL $args->[0]\n";
      }
    });


=head1 DESCRIPTION

=head1 SEE ALSO

There are a couple of modules that do similar things to this one:

=over 4

=item * L<Object::Event|Object::Event>

=item * L<Class::Observable|Class::Observable>

=item * L<Event::Notify|Event::Notify>

=item * L<Notification::Center|Notification::Center>

=back

Of those four, only L<Object::Event|Object::Event> version 1.0 and later
provides the same ability to pause a chain, do some asynchrounous work
and resume chain processing later.


=head1 AUTHOR

Pedro Melo, C<< <melo at cpan.org> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-async-hooks at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Async-Hooks>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Async::Hooks

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Async-Hooks>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Async-Hooks>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Async-Hooks>

=item * Search CPAN

L<http://search.cpan.org/dist/Async-Hooks>

=back


=head1 ACKNOWLEDGEMENTS

The code was inspired by the C<run_hook_chain> and C<hook_chain_fast>
code of the L<DJabberd project|DJabberd> (see the
L<DJabberd::VHost|DJabberd::VHost> module source code). Hat tip to Brad
Fitzpatrick.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Pedro Melo, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Async::Hooks
