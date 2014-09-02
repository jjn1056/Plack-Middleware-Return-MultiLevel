use strict;
use warnings;

package Plack::Middleware::Return::MultiLevel;

our $VERSION = "0.001";
use base 'Plack::Middleware';
use Plack::Util::Accessor 'level_name';
use Return::MultiLevel;

sub PSGI_KEY () { 'Plack.Middleware.Return.MultiLevel.return_to' }

sub DEFAULT_LEVEL_NAME() { 'default' }

sub __raw_level_name {
  my ($env, $level_name, $return_to) = @_;
  $env->{+PSGI_KEY}->{$level_name} = $return_to
    if $return_to;
  return $env->{+PSGI_KEY}->{$level_name};
}

sub _find_level_name_in {
  my ($env, $level_name) = @_;
  return __raw_level_name($env, $level_name) ||
    die "'$level_name' not found, cannot return to it!";
}

sub _set_level_name_in {
  my %env = %{(shift)};
  my ($level_name, $return_to) = @_;
  die "'$level_name' already defined"
    if __raw_level_name(\%env, $level_name);
  __raw_level_name(\%env, $level_name, $return_to);

  return \%env;
}

sub _return {
  my ($env, $level_name, @returning) = @_;
  my $returns_to = _find_level_name_in($env, $level_name);
  $returns_to->(@returning);
}

sub prepare_app {
  $_[0]->level_name(DEFAULT_LEVEL_NAME)
    unless(defined $_[0]->level_name);
}

sub call {
  my ($self, $env) = @_;
  return Return::MultiLevel::with_return {
    my ($return_to) = @_;
    my $new_env = _set_level_name_in($env, $self->level_name, $return_to);
    $self->app->($new_env);
  };
}

sub return {
  my ($self, $env, @returning) = @_;
  return _return($env, $self->level_name, @returning);
}

=head1 TITLE
 
Plack::Middleware::Return::MultiLevel - Escape a PSGI app from anywhere in the stack
 
=head1 SYNOPSIS

    TBD

=head1 DESCRIPTION

    TBD

=head1 CONSTANTS

This class defines the following constants

=head2 PSGI_KEY

PSGI environment key under which your return callback are stored.
 
=head1 METHODS
 
This class defines the following methods.

=head2 prepare_app

Sets instance defaults
 
=head2 call
 
Used by plack to call the middleware

=head2 return

    TBD

=head1 AUTHOR
 
John Napiorkowski L<email:jjnapiork@cpan.org>
 
=head1 SEE ALSO

L<Return::MultiLevel>, L<Plack>, L<Plack::Middleware>
 
=head1 COPYRIGHT & LICENSE
 
Copyright 2014, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
