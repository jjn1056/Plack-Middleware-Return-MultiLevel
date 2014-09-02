use strict;
use warnings;

package Plack::Middleware::Return::MultiLevel;

our $VERSION = "0.001";
use base 'Plack::Middleware';
use Plack::Util::Accessor 'level_name';
use Return::MultiLevel;
use Exporter 'import';

our @EXPORT_OK = qw(return_to_level return_to_default_level PSGI_KEY);

sub PSGI_KEY { return "Plack.Middleware.Return.MultiLevel.$VERSION" }

sub _DEFAULT_LEVEL_NAME { return 'default' }

sub _raw_level_name {
  my ($env, $level_name, $return_to) = @_;
  $env->{&PSGI_KEY}->{$level_name} = $return_to
    if $return_to;
  return $env->{&PSGI_KEY}->{$level_name};
}

sub _find_level_name_in {
  my ($env, $level_name) = @_;
  return _raw_level_name($env, $level_name) ||
    die "'$level_name' not found, cannot return to it!";
}

sub _set_level_name_in {
  my ($env, $level_name, $return_to) = @_;
  die "'$level_name' already defined"
    if _raw_level_name($env, $level_name);
  _raw_level_name($env, $level_name, $return_to);
}

sub _return {
  my ($env, $level_name, @returning) = @_;
  my $returns_to = _find_level_name_in($env, $level_name);
  $returns_to->(@returning);
}

sub return_to_level {
  my ($env, $level_name, @returning) = @_;
  return _return($env, $level_name, @returning);
}

sub return_to_default_level {
  my ($env, @returning) = @_;
  return _return($env, &_DEFAULT_LEVEL_NAME, @returning);
}

sub prepare_app {
  $_[0]->level_name(&_DEFAULT_LEVEL_NAME)
    unless(defined $_[0]->level_name);
}

sub call {
  my ($self, $env) = @_;
  return Return::MultiLevel::with_return {
    my ($return_to) = @_;
    _set_level_name_in($env, $self->level_name, $return_to);
    $self->app->($env);
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

=head1 EXPORTS

This class defines the following exportable subroutines

=head2 return_to_default_level

    TBD

=head2 return_to_level

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
