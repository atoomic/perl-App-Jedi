package App::Jedi::Actions::Launch;

# ABSTRACT: Launcher for your app

use Moo;
# VERSION
use MooX::Options;
use feature 'say';
use Jedi;
use Plack::Runner;

option 'name' => (is => 'ro', required => 1, doc => 'name of the app to launch', format => 's');

sub run {
	my ($self, $bundler) = @_;

	my $jedi = Jedi->new;
	$jedi->road('/', 'Jedi::App::' . $self->name);

	my $plack = Plack::Runner->new;
	return $plack->run($jedi->start);
}

1;
