package Gardel::Engine;
use base 'Mojo';

__PACKAGE__->attr( 'dispatch' );

=head1 NAME

Gardel::Engine - The http dispatcher engine for Gardel

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This is the internal 'Mojo' engine that match and exec the Gardel defined rules.

=head1 SYNOPSIS

    use Gardel::Engine;

    my $engine = Gardel::Engine->new(
        {   'GET' => [
                {   regex  => qr/^\/hello/,
                    action => sub {"Hello world!"}
                }
            ]
        }
    );

=cut

=head2 new

    Build a new Mojo handler for the given dispatch table.

=cut
sub new {
    my $self = shift->SUPER::new();
    
    if ( my $dispatch = shift ) {
        $self->dispatch( $dispatch );
    }

    # This app should log only errors to STDERR
    $self->log->level('error');
    $self->log->path(undef);

    return $self;
}

=head2 dispatch

    Set or retrieve the dispatch table structure.

=head2 handler

    This method will handle each request trying to match some defined
    rule on the requested http method or ANY (wildcard meta-method) 
    and executing that rule code.

=cut
sub handler {
    my ( $self, $tx ) = @_;

    unless ( $self->_handle( $tx => $tx->req->method )
          || $self->_handle( $tx => 'ANY' ) )
    {
        $tx->res->code(404);
        $tx->res->headers->content_type('text-plain');
        $tx->res->body( 'Page not found (404)' );
    }
}

=head2 _handle

    Match and exec a rule on the given method.

    The action will receive a Mojo::Transaction and a href with 
    the captured parameters from the matched rule if any.

=cut
sub _handle {
    my ($self, $tx, $method) = @_;

    my $handled = 0;

    if ( exists $self->dispatch->{ $method } ) {
        my $path = $tx->req->url->path->to_string;
        for my $rule ( @{ $self->dispatch->{$method} } ) {
            if ( my @capture = $path =~ $rule->{regex} ) {
                $tx->res->code(200);
                $tx->res->headers->content_type('text-html');

                #TODO: try to set a correct code and type looking on the generated body (when not setted only!)
                my $body_content = $rule->{action}->( $tx, $self->zip( $rule->{capture_name}, \@capture ) );
                $tx->res->body( $body_content ) unless $tx->res->body;

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

=head1 AUTHOR

Diego Kuperman, C<< <diego at freekeylabs.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Diego Kuperman, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Gardel
