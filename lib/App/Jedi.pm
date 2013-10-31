package App::Jedi;

# ABSTRACT: Jedi App Manager

=HEAD1 DESCRIPTION

Jedi App is a manager to install and deploy your jedi applications.

=cut

use strict;
use warnings;
# VERSION
use Moo;
use MooX::Options with_config_from_file => 1;
use feature 'say';
use Path::Class;
use Module::Runtime qw/use_module/;

=attr bundler_root_dir

The root dir where to install and deploy your app

=cut
option 'bundler_root_dir' => (
	'is' => 'ro',
	'format' => 's',
	'doc' => 'root dir where bundler install the deps of your apps',
	'default' => sub {'~/.jedi_bundler'},
	'coerce' => sub {
		$_[0] =~ s/\~/$ENV{'HOME'}/gx;
		dir($_[0]);
	},
);

around 'options_usage' => sub {
	my $orig = shift;
	my $self = shift;

	my %cmdline_params = $self->parse_options( help => 0 );
    my $usage = $cmdline_params{help};

    $usage->{leader_text} .= ' ACTIONS [ Actions Options ]';

    say $usage;
    say "The available actions are : ";
    say "";
    say "    * Check";
    say "    * Launch";
    say "";
	exit(0);
};

=method run

This is a class method to start your app

It will dispatch the command line between the manager and the action

=cut

sub run {

	my @argv_for_app_manager;
	my $action;
	while(@ARGV){
		if (index($ARGV[0], '-') == 0) {
			push @argv_for_app_manager, shift @ARGV;
		}
		else {
			$action = shift @ARGV;
			last;
		}
	}

	@argv_for_app_manager = '-h' if !defined $action;

	my $bundler = do {
		local @ARGV = @argv_for_app_manager;
		shift->new_with_options;
	};

	{
		my $class;
		if (eval{$class = use_module('App::Jedi::Actions::' . $action); 1}) {
			Getopt::Long::Descriptive::prog_name(Getopt::Long::Descriptive::prog_name . ' ' . $action);
			$class->new_with_options->run($bundler);
		} else {
			say "The action : \"$action\" is not available !";
			say "";
			$bundler->options_usage();
		} 
	}

	return;
}

1;
