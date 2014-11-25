package Git::Repository::Plugin::Blame::Cache;

use strict;
use warnings;

use Carp;
use Data::Validate::Type;


=head1 NAME

Git::Repository::Plugin::Blame::Cache - Cache the output of C<< Git::Repository->blame() >>.


=head1 VERSION

Version 1.2.3

=cut

our $VERSION = '1.2.3';

my $CACHE = {};


=head1 SYNOPSIS

	use Git::Repository::Plugin::Blame::Cache;

	# Instantiate the cache for a given repository.
	my $cache = Git::Repository::Plugin::Blame::Cache->new(
		repository => $repository,
	);

	my $repository = $cache->get_repository();

	# Cache blame lines.
	$cache->set_blame_lines(
		file        => $file,
		blame_lines => $blame_lines,
	);

	# Retrieve blame lines from the cache.
	my $blame_lines = $cache->get_blame_lines(
		file => $file,
	);


=head1 DESCRIPTION

Cache the output of C<< Git::Repository::Plugin::Blame->blame() >> and
C<< Git::Repository->blame() >> by extension.


=head1 METHODS

=head2 new()

Return a cache object for the specified repository.

	my $cache = Git::Repository::Plugin::Blame::Cache->new(
		repository => $repository,
	);

Arguments:

=over 4

=item * repository (mandatory)

A unique way to identify a repository. Typically, the root path of the
repository.

=back

=cut

sub new
{
	my ( $class, %args ) = @_;
	my $repository = delete( $args{'repository'} );
	croak 'The following arguments are not valid: ' . join( ',', keys %args )
		if scalar( keys %args ) != 0;

	croak 'The "repository" argument is mandatory'
		if !defined( $repository ) || $repository eq '';

	if ( !defined( $CACHE->{ $repository } ) )
	{
		$CACHE->{ $repository } = bless(
			{
				repository => $repository,
				files      => {},
			},
			$class,
		);
	}

	return $CACHE->{ $repository };
}


=head2 get_repository()

Return the unique identifier for the repository.

	my $repository = $cache->get_repository();

=cut

sub get_repository
{
	my ( $self ) = @_;

	return $self->{'repository'};
}


=head2 get_blame_lines()

Retrieve git blame lines from the cache (if they exist) for a given file.

	my $blame_lines = $cache->get_blame_lines(
		file => $file,
	);

Arguments:

=over 4

=item * file (mandatory)

The file for which you want the cached C<git blame> output.

=back

=cut

sub get_blame_lines
{
	my ( $self, %args ) = @_;
	my $file = delete( $args{'file'} );
	croak 'The following arguments are not valid: ' . join( ',', keys %args )
		if scalar( keys %args ) != 0;

	croak 'The "file" argument is mandatory'
		if !defined( $file ) || ( $file eq '' );

	return $self->{'files'}->{ $file };
}


=head2 set_blame_lines()

Store in the cache the output of C<git blame> for a given file.

	$cache->set_blame_lines(
		file        => $file,
		blame_lines => $blame_lines,
	);

Arguments:

=over 4

=item * file (mandatory)

The file for which you are caching the C<git blame> output.

=item * blame_lines (mandatory)

The output of C<< Git::Repository::Plugin::Blame->blame() >>.

=back

=cut

sub set_blame_lines
{
	my ( $self, %args ) = @_;
	my $file = delete( $args{'file'} );
	my $blame_lines = delete( $args{'blame_lines'} );
	croak 'The following arguments are not valid: ' . join( ',', keys %args )
		if scalar( keys %args ) != 0;

	croak 'The "file" argument is mandatory'
		if !defined( $file ) || $file eq '';
	croak 'The "blame_lines" argument is mandatory'
		if !defined( $blame_lines );
	croak 'The "blame_lines" argument must be an arrayref'
		if !Data::Validate::Type::is_arrayref( $blame_lines );

	$self->{'files'}->{ $file } = $blame_lines;

	return;
}


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/Git-Repository-Plugin-Blame/issues>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc Git::Repository::Plugin::Blame


You can also look for information at:

=over 4

=item * GitHub (report bugs there)

L<https://github.com/guillaumeaubert/Git-Repository-Plugin-Blame/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Git-Repository-Plugin-Blame>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Git-Repository-Plugin-Blame>

=item * MetaCPAN

L<https://metacpan.org/release/Git-Repository-Plugin-Blame>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2012-2014 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
