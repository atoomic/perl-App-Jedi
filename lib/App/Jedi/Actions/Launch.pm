package App::Jedi::Actions::Launch;

# ABSTRACT: Launcher for your app

use Moo;
# VERSION
use MooX::Options;
use feature 'say';
use App::Jedi::Actions::Check;
use Module::Runtime qw/use_module/;

option 'name' => (is => 'ro', required => 1, doc => 'name of the app to launch', format => 's');

sub run {
	my ($self, $jedi_manager) = @_;

	App::Jedi::Actions::Check->new->run($jedi_manager);

	my $jedi = use_module('Jedi')->new;
	$jedi->road('/', 'Jedi::App::' . $self->name);

	my $plack = use_module('Plack::Runner')->new;
	return $plack->run($jedi->start);
}

1;
