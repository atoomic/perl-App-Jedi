package App::Jedi;

# ABSTRACT: Jedi App Manager

=HEAD1 DESCRIPTION

=cut

use strict;
use warnings;
# VERSION
use Moo;
use MooX::Options flavour => [qw( pass_through )], with_config_from_file => 1;
use Getopt::Long::Descriptive;
use feature 'say';
use Path::Class;
use Module::Runtime qw/use_module/;

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
    say "The available actions is : ";
    say "";
    say "    * Check";
    say "";
	exit(0);
};

sub run {

	my @ARGV_FOR_BUNDLER;
	my @ARGV_FOR_ACTION;
	my $action;
	while(@ARGV){
		if (index($ARGV[0], '-') == 0) {
			push @ARGV_FOR_BUNDLER, shift @ARGV;
		}
		else {
			$action = shift @ARGV;
			@ARGV_FOR_ACTION = @ARGV;
			last;
		}
	}

	@ARGV_FOR_BUNDLER = '-h' if !defined $action;

	my $bundler = do {
		local @ARGV = @ARGV_FOR_BUNDLER;
		shift->new_with_options;
	};

	{
		local @ARGV = @ARGV_FOR_ACTION;
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
