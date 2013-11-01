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
	my ($self, $jedi_manager) = @_;

	say "Root Dir : ", $jedi_manager->root_dir;
	say "Install Dir : ", $jedi_manager->install_dir;

	$jedi_manager->root_dir->mkpath;
	$jedi_manager->install_dir->mkpath;
	dir($jedi_manager->root_dir, 'bin')->mkpath;

	my $cpanm = $jedi_manager->root_dir->file('bin','cpanm');
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
		"-l", $jedi_manager->install_dir,
		"-L", $jedi_manager->install_dir,
		"-nq",
		"Jedi");

	return;
}

1;
