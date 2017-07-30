#!/usr/bin/env perl
use inc::Module::Install 1.02;

name 'Cath-Tiny';

all_from 'lib/Cath/Tiny.pm';

requires 'Moo' => '';
requires 'MooX::Options' => '';
requires 'MooX::Cmd' => '';
requires 'namespace::autoclean' => '';
requires 'JSON::MaybeXS' => '';
requires 'Path::Tiny' => '';
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
requires 'CHI';
requires 'MooX::Cmd';
requires 'MooX::Options';
requires 'MooX::Log::Any';
requires 'Types::Path::Tiny';
requires 'Log::Any::Adapter::Dispatch';

WriteAll;
