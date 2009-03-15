use inc::Module::Install;

name     'Async-Hooks';
all_from 'lib/Async/Hooks.pm';
author   'Pedro Melo <melo@cpan.org>';

build_requires 'Test::More';

auto_install;

WriteAll;

