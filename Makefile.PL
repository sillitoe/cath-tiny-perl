#!/usr/bin/env perl
use inc::Module::Install 1.02;

name 'Cath-Tiny';

all_from 'lib/Cath/Tiny.pm';

requires 'JSON::Any' => '';
requires 'Moo' => '';
requires 'MooX::Options' => '';
requires 'MooX::Cmd' => '';
requires 'namespace::autoclean' => '';
requires 'Path::Class' => '';
requires 'Params::Validate' => '';
requires 'REST::Client' => '';
requires 'Try::Tiny' => '';
requires 'Type::Library' => '';
requires 'Type::Utils' => '';
requires 'Types::Standard' => '';
requires 'Log::Dispatch';
requires 'Text::LineFold';
requires 'Type::Tiny';
requires 'IO::String';
requires 'URI';

WriteAll;
