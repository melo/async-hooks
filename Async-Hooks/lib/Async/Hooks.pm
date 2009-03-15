package Async::Hooks;

use Mouse;

our $VERSION = '0.01';


no Mouse;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Async::Hooks - The great new Async::Hooks!


=head1 VERSION

Version 0.01


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Async::Hooks;

    my $foo = Async::Hooks->new();
    ...



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


=head1 COPYRIGHT & LICENSE

Copyright 2009 Pedro Melo, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Async::Hooks
