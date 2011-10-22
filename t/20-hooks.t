#!perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Deep;
use Test::Fatal;

use Async::Hooks;

my $nc = Async::Hooks->new;
ok($nc);
my $r = $nc->registry;
ok($r);
is(ref($r),     'HASH');
is(scalar(%$r), 0);

is($nc->has_hooks_for('h1'), 0);

my %called;

$nc->hook(
  'h1',
  sub {
    my ($ctl) = @_;
    $called{'h1_1'}++;
    return $ctl->next;
  }
);
$r = $nc->registry;
is(scalar(keys %$r),         1);
is($nc->has_hooks_for('h1'), 1);

$nc->hook(
  'h1',
  sub {
    my ($ctl) = @_;
    $called{'h1_2'}++;
    return $ctl->next;
  }
);
$r = $nc->registry;
is(scalar(keys %$r),         1);
is($nc->has_hooks_for('h1'), 2);

is($nc->has_hooks_for('h2'), 0);
$nc->hook(
  'h2',
  sub {
    my ($ctl) = @_;
    $called{'h2_1'}++;
    return $ctl->decline;
  }
);
$r = $nc->registry;
is(scalar(keys %$r), 2);

$nc->hook(
  'h2',
  sub {
    my ($ctl) = @_;
    $called{'h2_2'}++;
    return $ctl->done;
  }
);
is($nc->has_hooks_for('h2'), 2);


### Test a couple of times to see if first runs messes up internals
foreach my $try (1 .. 3) {
  %called = ();
  $nc->call('h1');
  cmp_deeply(\%called, {h1_1 => 1, h1_2 => 1}, "h1, try $try");

  %called = ();
  $nc->call('h2', [], sub { $called{'clean'}++ });
  cmp_deeply(\%called, {h2_1 => 1, h2_2 => 1, clean => 1}, "h2, try $try");

  %called = ();
  $nc->call('non-existent');
  cmp_deeply(\%called, {}, "non-existent, try $try");

  %called = ();
  $nc->call('non-existent', [], sub { $called{'clean'}++ });
  cmp_deeply(\%called, {clean => 1}, "non-existent with clean, try $try");
}


### Test is_done flag
$nc->call(
  'h1',
  [],
  sub {
    my ($ctl, $args, $is_done) = @_;

    isa_ok($ctl, 'Async::Hooks::Ctl');
    is(ref($args),     'ARRAY');
    is(scalar(@$args), 0);
    ok(defined($is_done));
    ok(!$is_done);
  }
);

$nc->call(
  'h2',
  [1, 2],
  sub {
    my ($ctl, $args, $is_done) = @_;

    isa_ok($ctl, 'Async::Hooks::Ctl');
    is(ref($args),     'ARRAY');
    is(scalar(@$args), 2);
    ok(defined($is_done));
    ok($is_done);
  }
);


### Test modifiable args

$nc->hook(
  'i1',
  sub {
    my ($ctl, $args) = @_;
    ok($args->[0]);
    my $value = $args->[0]++;

    return $ctl->next if $value % 2 == 0;
    return $ctl->done;
  }
);

$nc->hook(
  'i1',
  sub {
    my ($ctl, $args) = @_;
    ok($args->[0]);
    $args->[0] += 2;
    $args->[1] = '';

    return $ctl->next;
  }
);
is($nc->has_hooks_for('i1'), 2);

$nc->call(
  'i1',
  [1, 'aa'],
  sub {
    my ($ctl, $args, $is_done) = @_;
    is($args->[0], 2);
    is($args->[1], 'aa');
    ok($is_done);
  }
);

$nc->call(
  'i1',
  [2, 'bb'],
  sub {
    my ($ctl, $args, $is_done) = @_;
    is($args->[0], 5);
    is($args->[1], '');
    ok(!$is_done);
  }
);


### Test API abuse
like(
  exception {
    $nc->hook;
  },
  qr/Missing first parameter, the hook name,/
);

like(
  exception {
    $nc->hook('hook');
  },
  qr/Missing second parameter, the coderef callback,/
);

like(
  exception {
    $nc->hook('hook', 'method');
  },
  qr/Missing second parameter, the coderef callback,/
);

like(
  exception {
    $nc->hook(undef, sub { });
  },
  qr/Missing first parameter, the hook name,/
);


like(
  exception {
    $nc->call;
  },
  qr/Missing first parameter, the hook name,/
);

like(
  exception {
    $nc->call('hook', 'wtf');
  },
  qr/Second parameter, the arguments list, must be a arrayref,/
);

like(
  exception {
    $nc->call('hook', {});
  },
  qr/Second parameter, the arguments list, must be a arrayref,/
);

like(
  exception {
    $nc->call('hook', undef, 'method');
  },
  qr/Third parameter, the cleanup callback, must be a coderef,/
);

like(
  exception {
    $nc->call('hook', [], 'method');
  },
  qr/Third parameter, the cleanup callback, must be a coderef,/
);


### Make sure we keep our house clean
for my $m (qw(confess has extends)) {
  ok(!$nc->can($m), "Async::Hooks has no '$m' method, good");
}
