#!perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Deep;
use Test::Exception;

use Async::Hooks;

my $nc = Async::Hooks->new;
ok($nc);
my $r = $nc->registry;
ok($r);
is(ref($r), 'HASH');
is(scalar(%$r), 0);

my %called;

$nc->hook('h1', sub {
  my ($ctl) = @_;
  $called{'h1_1'}++;
  return $ctl->next;
});
$r = $nc->registry;
is(scalar(keys %$r), 1);

$nc->hook('h1', sub {
  my ($ctl) = @_;
  $called{'h1_2'}++;
  return $ctl->next;
});
$r = $nc->registry;
is(scalar(keys %$r), 1);

$nc->hook('h2', sub {
  my ($ctl) = @_;
  $called{'h2_1'}++;
  return $ctl->decline;
});
$r = $nc->registry;
is(scalar(keys %$r), 2);

$nc->hook('h2', sub {
  my ($ctl) = @_;
  $called{'h2_2'}++;
  return $ctl->done;
});


### Test a couple of times to see if first runs messes up internals
foreach my $try (1..3) {
  %called = ();
  $nc->call('h1');
  cmp_deeply(\%called, { h1_1 => 1, h1_2 => 1 }, "h1, try $try");

  %called = ();
  $nc->call('h2', [], sub { $called{'clean'}++ });
  cmp_deeply(\%called, { h2_1 => 1, h2_2 => 1, clean => 1 }, "h2, try $try");

  %called = ();
  $nc->call('non-existent');
  cmp_deeply(\%called, {}, "non-existent, try $try");

  %called = ();
  $nc->call('non-existent', [], sub { $called{'clean'}++ });
  cmp_deeply(\%called, { clean => 1 }, "non-existent with clean, try $try");
}


### Test is_done flag
$nc->call('h1', [], sub {
  my ($ctl, $args, $is_done) = @_;

  isa_ok($ctl, 'Async::Hooks::Ctl');
  is(ref($args), 'ARRAY');
  is(scalar(@$args), 0);
  ok(defined($is_done));
  ok(!$is_done);
});

$nc->call('h2', [1, 2], sub {
  my ($ctl, $args, $is_done) = @_;

  isa_ok($ctl, 'Async::Hooks::Ctl');
  is(ref($args), 'ARRAY');
  is(scalar(@$args), 2);
  ok(defined($is_done));
  ok($is_done);
});


### Test API abuse
throws_ok sub {
  $nc->hook;
}, qr/Missing first parameter, the hook name,/;

throws_ok sub {
  $nc->hook('hook');
}, qr/Missing second parameter, the coderef callback,/;

throws_ok sub {
  $nc->hook('hook', 'method');
}, qr/Missing second parameter, the coderef callback,/;

throws_ok sub {
  $nc->hook(undef, sub {});
}, qr/Missing first parameter, the hook name,/;


throws_ok sub {
  $nc->call;
}, qr/Missing first parameter, the hook name,/;

throws_ok sub {
  $nc->call('hook', 'wtf');
}, qr/Second parameter, the arguments list, must be a arrayref,/;

throws_ok sub {
  $nc->call('hook', {});
}, qr/Second parameter, the arguments list, must be a arrayref,/;

throws_ok sub {
  $nc->call('hook', sub {});
}, qr/Second parameter, the arguments list, must be a arrayref,/;

throws_ok sub {
  $nc->call('hook', undef, 'method');
}, qr/Third parameter, the cleanup callback, must be a coderef,/;

throws_ok sub {
  $nc->call('hook', [], 'method');
}, qr/Third parameter, the cleanup callback, must be a coderef,/;

