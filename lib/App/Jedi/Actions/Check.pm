package App::Jedi::Actions::Check;

# ABSTRACT: Check installation

use Moo;
# VERSION
use MooX::Options;
use feature 'say';

sub run {
	my ($self, $bundler) = @_;

	say "Bundle Dir : ", $bundler->bundler_root_dir;
	say  "Config Dir : ", join(":", @{$bundler->config_dirs});

	return;
}

1;
