package Git::Repository::Plugin::Blame;

use warnings;
use strict;
use 5.006;

use Git::Repository::Plugin;
our @ISA = qw( Git::Repository::Plugin );
sub _keywords { return qw( blame ) } ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)

use Carp;
use Perl6::Slurp qw();
use Git::Repository::Plugin::Blame::Line;


=head1 NAME
 
Git::Repository::Plugin::Blame - Add a blame() method to L<Git::Repository>.


=head1 VERSION

Version 1.0.2

=cut

our $VERSION = '1.0.2';


=head1 SYNOPSIS

	# Load the plugin.
	use Git::Repository 'Blame';
	
	my $repository = Git::Repository->new();
	
	# Get the git blame information.
	my $blame_lines = $repository->blame( $file );


=head1 DESCRIPTION

This module adds a new C<blame()> method to L<Git::Repository>, which can be
used to determine what the last change for each line in a file is.


=head1 METHODS

=head2 blame()

Return the git blame information for a given file as an arrayref of
L<Git::Repository::Plugin::Blame::Line> objects.

	my $blame_lines = $repository->blame( $file );

=cut

sub blame
{
	my ( $repository, $file ) = @_;
	
	# Run the command.
	my $command = $repository->command( 'blame', '--porcelain', $file );
	my @output = $command->final_output();
	
	# Parse the output.
	my ( $commit_id, $original_line_number, $final_line_number, $lines_count_in_group );
	my $commit_attributes = {};
	my $lines = [];
	foreach my $line ( @output )
	{
		if ( $line =~ /^\t(.*)$/x )
		{
			# It's a line from the file we git blamed.
			push(
				@$lines,
				Git::Repository::Plugin::Blame::Line->new(
					line_number       => $final_line_number,
					line              => defined( $1 ) ? $1 : '',
					commit_attributes => $commit_attributes->{ $commit_id },
					commit_id         => $commit_id,
				)
			);
		}
		else
		{
			# It's a git header line.
			if ( $line =~ /^([0-9a-f]+)\s(\d+)\s(\d+)\s*(\d*)$/x )
			{
				( $commit_id, $original_line_number, $final_line_number, $lines_count_in_group ) = ( $1, $2, $3, $4 );
			}
			elsif ( $line =~ m/^([\w\-]+)\s*(.*)$/x )
			{
				$commit_attributes->{ $commit_id }->{ $1 } = $2;
			}
		}
	}
	
	return $lines;
}


=head1 AUTHOR

Guillaume Aubert, C<< <aubertg at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-git-repository-plugin-blame at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Git-Repository-Plugin-Blame>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc Git::Repository::Plugin::Blame


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Git-Repository-Plugin-Blame>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Git-Repository-Plugin-Blame>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Git-Repository-Plugin-Blame>

=item * Search CPAN

L<http://search.cpan.org/dist/Git-Repository-Plugin-Blame/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2012 Guillaume Aubert.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
