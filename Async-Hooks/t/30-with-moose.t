#!perl

use strict;
use warnings;
use Test::More 'no_plan';
use Async::Hooks;

eval "use Moose";
plan skip_all => "Moose is required for these cute tests" if $@;

package ChocolateMoose;

use Moose;

has 'hooks' => (
  isa     => 'Async::Hooks',
  is      => 'ro',
  default => sub { Async::Hooks->new },
  lazy    => 1,
  handles => [qw( hook call )],
);

sub bork {
  return shift->call('bork?');
}

package main;

my $cm = ChocolateMoose->new;
my $borked;

$cm->hook('bork?', sub {
  my ($ctl) = @_;
  ok(1, 'borked just fine...');
  $borked++;
  $ctl->next;
});

$cm->bork;
is($borked, 1);
