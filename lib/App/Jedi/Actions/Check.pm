package App::Jedi::Actions::Check;

# ABSTRACT: Check installation

use Moo;
# VERSION
use MooX::Options;
use LWP::Protocol::https;
use LWP::Simple;
use feature 'say';
use Path::Class;
use Carp;

sub run {
	my ($self, $bundler) = @_;

	say "Bundle Dir : ", $bundler->bundler_root_dir;
	$bundler->bundler_root_dir->mkpath;
	dir($bundler->bundler_root_dir, 'bin')->mkpath;

	my $perl_check = $bundler->bundler_root_dir->file('PERL_VERSION');
	if (!-e $perl_check) {
		$perl_check->spew($^V);
	} else {
		my $perl_version = $perl_check->slurp;
		if ($perl_version ne $^V) {
			croak 
			join("\n",
			  "The current perl version is different than the one use for installation."
			, "Current : " . $^V
			, "Install : " . $perl_version
			, ""
			, "We have XS installed here, you need to remove and reinstall the bundle dir."
			);
		}
	}

	my $cpanm = $bundler->bundler_root_dir->file('bin','cpanm');
	if (!-f $cpanm) {
		say "Fetching cpanm ...";
		my $cpanm_source = get('http://cpanmin.us');
		if (length($cpanm_source)) {
			$cpanm->spew($cpanm_source);
		} else {
			croak "Cannot fetch cpanm ...";
		}
	}

	say "Installing Jedi requirements ...";
	system(
		$^X, $cpanm->stringify, 
		"--mirror-only", 
		"--mirror", "http://cpan.celogeek.fr", 
		"--mirror", "http://cpan.org", 
		"-l", $bundler->bundler_root_dir, 
		"-L", $bundler->bundler_root_dir, 
		"-nq", 
		"Jedi");

	return;
}

1;
