#!perl

# Note: cannot use -T here, Git::Repository uses environment variables directly.

use strict;
use warnings;

use Git::Repository ( 'Blame', 'Log' );
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::Git;
use Test::More;


# Check there is a git binary available, or skip all.
has_git();

plan( tests => 14 );

# Create a new, empty repository in a temporary location and return
# a Git::Repository object.
my $repository = Test::Git::test_repository();

my $work_tree = $repository->work_tree();
ok(
	defined( $work_tree ) && -d $work_tree,
	'Find the work tree for the temporary test repository.',
);

# Set up the default author.
$ENV{'GIT_AUTHOR_NAME'} = 'Author1';
$ENV{'GIT_AUTHOR_EMAIL'} = 'author1@example.com';
$ENV{'GIT_COMMITTER_NAME'} = 'Author1';
$ENV{'GIT_COMMITTER_EMAIL'} = 'author1@example.com';

# Create a new file.
my $test_file = $work_tree . '/README';
ok(
	open( my $fh, '>', $test_file ),
	'Create test file.'
) || diag( "Failed to open $test_file for writing: $!" );
print $fh "Test 1.\n";
print $fh "Test 2.\n";
print $fh "Test 3.\n";
close( $fh );

# Add the file to git.
lives_ok(
	sub
	{
		$repository->run( 'add', $test_file );
	},
	'Add test file to the Git index.',
);
lives_ok(
	sub
	{
		$repository->run( 'commit', '-m "First commit."' );
	},
	'Commit to Git.',
);
ok(
	my ( $log ) = $repository->log( '-1' ),
	'Retrieve the log of the commit.',
);
ok(
	defined( my $commit1_id = $log->commit() ),
	'Retrieve the commit ID.',
);

# Modify the file.
ok(
	open( $fh, '>', $test_file ),
	'Modify test file.'
) || diag( "Failed to open $test_file for writing: $!" );
print $fh "Test 1.\n";
print $fh "Test 2.a.\n";
print $fh "Test 2.b.\n";
print $fh "Test 3.\n";
close( $fh );

# Commit the changes to git.
lives_ok(
	sub
	{
		$repository->run( 'commit', '-m "Second commit."', '-a' );
	},
	'Commit to Git.',
);
ok(
	( $log ) = $repository->log( '-1' ),
	'Retrieve the log of the commit.',
);
ok(
	defined( my $commit2_id = $log->commit() ),
	'Retrieve the commit ID.',
);

# Get the blame information.
my $blame_lines;
lives_ok(
	sub
	{
		$blame_lines = $repository->blame( $test_file );
	},
	'Retrieve git blame information.',
);

isa_ok(
	$blame_lines,
	'ARRAY',
	'Blame information',
);

is(
	scalar( @$blame_lines ),
	4,
	'Verify the number of lines with blame information',
);

# Test the blame lines.
my $expected_commit_ids =
[
	$commit1_id,
	$commit2_id,
	$commit2_id,
	$commit1_id,
];

subtest(
	'The blame lines match expected information.',
	sub
	{
		plan( tests => 4 * scalar( @$blame_lines ) );
		my $count = 0;
		foreach my $blame_line ( @$blame_lines )
		{
			$count++;
			note( "Check line $count:" );
			isa_ok(
				$blame_line,
				'Git::Repository::Plugin::Blame::Line',
				"Blame information for line $count",
			);
			is(
				$blame_line->get_line_number(),
				$count,
				'The line number is correctly set on the object.',
			);
			
			my $commit_attributes = $blame_line->get_commit_attributes();
			ok(
				defined( $commit_attributes ),
				'The commit attributes are defined.',
			);
			
			is(
				$blame_line->get_commit_id(),
				$expected_commit_ids->[ $count - 1 ],
				'The commit ID reported by git blame is correct.',
			);
			
		}
	}
);
