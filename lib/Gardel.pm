package Gardel;

use warnings;
use strict;

use base qw/ 
    Exporter 
    HTTP::Server::Simple::CGI 
/;

our @EXPORT = qw/ 
    GET 
    POST 
    PUT 
    DELETE 
    ANY
    config
/;

our $dispatch = {};

sub GET($&)    { _add_rule( 'GET'    => @_ ) }
sub POST($&)   { _add_rule( 'POST'   => @_ ) }
sub DELETE($&) { _add_rule( 'DELETE' => @_ ) }
sub PUT($&)    { _add_rule( 'PUT'    => @_ ) }
sub ANY($&)    { _add_rule( 'ANY'    => @_ ) }

sub config($)  { $dispatch->{config} = shift }

=head1 NAME

Gardel - The great tango star that also has a hat!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

You can run a webapp running just this code:

    use Gardel;

    GET '/about'       => sub { 'This is just a Gardel demo app' };
    GET '/hello/:word' => sub { 'Hello ' . $_[1]->{word} };
    PUT '/upload'      => sub { # store the file! };

=head1 FUNCTIONS

=head2 GET
=head2 POST
=head2 DELETE
=head2 PUT
=head2 ANY
=head2 config

=head2 _add_rule

    Create a rule on for the given route for the given http method.

=cut
sub _add_rule {
    my ( $method, $route_def, $action_sub ) = @_;

    push @{$dispatch->{$method}}, create_rule( $route_def, $action_sub );
}

=head2 handle_request

    This method will handle each request trying to match some defined
    rule on the requested http method or ANY (wildcard meta-method) 
    and executing that rule code.

=cut
sub handle_request {
    my ( $self, $cgi ) = @_;

    unless ( $self->_handle( $cgi => $cgi->request_method )
          || $self->_handle( $cgi => 'ANY' ) )
    {
        print "HTTP/1.0 404 Not found\r\n";
        print $cgi->header,
            $cgi->start_html('Not found'),
            $cgi->h1('Not found'),
            $cgi->end_html;
    }
}

=head2 _handle

    Match and exec a rule on the given method

=cut
sub _handle {
    my ($self, $cgi, $method) = @_;

    my $handled = 0;

    if ( exists $dispatch->{ $method } ) {
        my $path = $cgi->path_info();
        for my $rule ( @{ $dispatch->{$method} } ) {
            if ( my @capture = $path =~ $rule->{regex} ) {
                print "HTTP/1.0 200 OK\r\n";
                print $cgi->header;
                print $rule->{action}->($cgi, $self->zip( $rule->{capture_name}, \@capture ) );
                $handled++;
            }
        }
    }

    return $handled;
}

=head2 zip

    Just a helper method to create a hash from two arrays (must use a module)

=cut
sub zip {
    my ( $self, $keys, $values ) = @_;

    my $hr = {};
    for my $key ( @$keys ) {
        $hr->{ $key } = shift @$values;
    }

    return $hr;
}

=head2 create_rule

=cut
sub create_rule {
    my ( $route, $action ) = @_;

    $route =~ s/^\///; # <--- para que funcione el generador de regex (sino mete doble barra)

    my $rule = { regex => '^', action => $action };
    for my $fragment ( split '/', $route ) {
        if ( $fragment =~ /^:(.+)/ ) {
            push @{$rule->{capture_name}}, $1;
            $rule->{regex} .= '/([^/]+)';
        }
        else {
            $rule->{regex} .= '/' . $fragment;
        }
    }

    # Append again the '/' when defining a root rule
    $rule->{regex} .= '/' if $rule->{regex} eq '^';

    # Don't match anything longer :)
    my $re = $rule->{regex} . '$';

    # Store the rule compiled
    $rule->{regex} = qr/$re/;

    return $rule;
}

# Start engines!, go -> :)
END {
    unless ( $dispatch->{config}{test} || $ENV{GARDEL_TEST} ) {
        my $server = __PACKAGE__->new( $dispatch->{config}{port} || 3000 );
        if ( $dispatch->{config}{daemon} ) {
            my $pid = $server->background();
            print STDERR "Use 'kill $pid' to stop server.\n";
        }
        else {
            print STDERR "Use ctrl+c to stop server.\n";
            $server->run();
        }
    }
}

=head1 AUTHOR

Diego Kuperman, C<< <diego at freekeylabs.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-gardel at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gardel>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gardel


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Gardel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Gardel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Gardel>

=item * Search CPAN

L<http://search.cpan.org/dist/Gardel>

=back

=head1 ACKNOWLEDGEMENTS

This software was hardly inspired on the sinatra web framework.

L<http://sinatrarb.com>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Diego Kuperman, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Gardel
