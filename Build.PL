use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Gardel',
    license             => 'perl',
    dist_author         => 'Diego Kuperman <diego@freekeylabs.com>',
    dist_version_from   => 'lib/Gardel.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'HTTP::Server::Simple::CGI'  => 0,
    },
    add_to_cleanup      => [ 'Gardel-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
