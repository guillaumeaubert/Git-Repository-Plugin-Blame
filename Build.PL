use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name          => 'Git::Repository::Plugin::Blame',
	license              => 'artistic',
	dist_author          => q{Guillaume Aubert <aubertg@cpan.org>},
	dist_version_from    => 'lib/Git/Repository/Plugin/Blame.pm',
	build_requires       =>
	{
		'Data::Dumper'            => 0,
		'Carp'                    => 0,
		'Git::Repository'         => 1.20,
		'Perl6::Slurp'            => 0,
		'Test::Deep'              => 0,
		'Test::Exception'         => 0,
		'Test::Git'               => 0,
		'Test::More'              => 0,
	},
	requires             =>
	{
		'perl' => 5.006,
	},
	add_to_cleanup       =>
	[
		'Git-Repository-Plugin-Blame-*',
	],
	create_makefile_pl   => 'traditional',
	recursive_test_files => 1,
	configure_requires   =>
	{
		'Module::Build'           => 0,
	},
	meta_merge           =>
	{
		resources                 =>
		{
			repository  => 'https://github.com/guillaumeaubert/Git-Repository-Plugin-Blame',
			homepage    => 'https://metacpan.org/release/Git-Repository-Plugin-Blame',
			bugtracker  => 'https://github.com/guillaumeaubert/Git-Repository-Plugin-Blame/issues',
		},
	},
);

$builder->create_build_script();
