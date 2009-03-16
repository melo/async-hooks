#!perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Deep;
use Test::Exception;
use Async::Hooks::Ctl;

my %called;
sub reset { %called = () }

sub mark1 {
  $called{'mark1'}++;
  return $_[0]->decline;
}

sub mark2 {
  $called{'mark2'}++;
  return $_[0]->declined;
}

sub mark3 {
  $called{'mark3'}++;
  return $_[0]->next;
}

sub bad_mark1 {
  $called{'bad_mark1'}++;
  return;
}

sub done1 {
  $called{'done1'}++;
  return $_[0]->done;
}

sub done2 {
  $called{'done2'}++;
  return $_[0]->stop;
}

sub later1 {
  my ($ctl, $args) = @_;

  $called{'later1'}++;
  ${$args->[0]} = $ctl;

  return;
}

sub cleanup {
  $called{'cleanup'}++;
}


### Test args
my $ctl = Async::Hooks::Ctl->new();
cmp_deeply($ctl->args, []);
%called = ();
lives_ok sub { $ctl->next };
cmp_deeply(\%called, {});

$ctl = Async::Hooks::Ctl->new([], [1, 2, 3]);
cmp_deeply($ctl->args, [1, 2, 3]);
%called = ();
lives_ok sub { $ctl->decline };
cmp_deeply(\%called, {});


### test hooks
$ctl = Async::Hooks::Ctl->new(
  [ \&mark1, \&mark2, \&done1, \&mark3 ],
);
%called = ();
lives_ok sub { $ctl->declined };
cmp_deeply(
  \%called,
  { mark1 => 1, mark2 => 1, done1 => 1 },
);

$ctl = Async::Hooks::Ctl->new(
  [ \&mark2, \&mark2, \&done2, \&done1],
  [],
  \&cleanup,
);
%called = ();
lives_ok sub { $ctl->declined };
cmp_deeply(
  \%called,
  { mark2 => 2, done2 => 1, cleanup => 1 },
);

$ctl = Async::Hooks::Ctl->new(
  [ \&mark2, \&mark2, \&bad_mark1, \&mark3 ],
  [],
);
%called = ();
lives_ok sub { $ctl->declined };
cmp_deeply(
  \%called,
  { mark2 => 2, bad_mark1 => 1 },
);

my $later_cb;
$ctl = Async::Hooks::Ctl->new(
  [ \&mark1, \&mark2, \&later1, \&mark3 ],
  [ \$later_cb ],
);
%called = ();
lives_ok sub { $ctl->declined };
cmp_deeply(
  \%called,
  { mark1 => 1, mark2 => 1, later1 => 1 },
);
%called = ();
lives_ok sub { $later_cb->next };
cmp_deeply(
  \%called,
  { mark3 => 1 },
);

