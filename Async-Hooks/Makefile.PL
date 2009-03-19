use inc::Module::Install;

name     'Async-Hooks';
version  '0.01';
abstract 'Hook system with asynchronous capabilities';
author   'Pedro Melo <melo@cpan.org>';
license  'perl';
repository 'http://github.com/melo/perl-async-hooks/';
perl_version '5.008';

requires 'Mouse' => 0;

build_requires 'Test::More';
build_requires 'Test::Deep';
build_requires 'Test::Exception';

auto_install;

WriteAll;
