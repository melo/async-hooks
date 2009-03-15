use inc::Module::Install;

name     'Async-Hooks';
all_from 'lib/Async/Hooks.pm';
author   'Pedro Melo <melo@cpan.org>';

requires 'Mouse' => 0;

build_requires 'Test::More';
build_requires 'Test::Deep';
build_requires 'Test::Exception';

auto_install;

WriteAll;

