use strict;
use warnings;

package Plack::Middleware::Return::MultiLevel;

our $VERSION = "0.001";
use base 'Plack::Middleware';
use Plack::Util::Accessor 'level_name';
use Return::MultiLevel;

sub _PSGI_KEY_BASE { 'Plack.Middleware.Return.MultiLevel.$VERSION' }
 
sub returns {
  my ($self_or_class, $env, $level_name, @returning) = ();
  if(ref($_[0])) {
    ($self_or_class, $env, @returning) = @_;
  } else {
    ($self_or_class, $level_name, $env, @returning) = @_;
  }

  $env->{$self_or_class->env_key($level_name)}->(@returning);
}

sub env_key {
  my ($self_or_class, $level_name) = @_;
  return join '.', (&_PSGI_KEY_BASE, ($level_name||shift->level_name||''));
}

sub call {
  my ($self, $env) = @_;
  die "You may not use an existing 'level_name'" if
    $env->{$self->env_key};

  return Return::MultiLevel::with_return {
    my ($return) = @_;
    $env->{$self->env_key} = $return;
    $self->app->($env);
  };
}

 
=head1 TITLE
 
Plack::Middleware::Return::MultiLevel - Escape a PSGI app from anywhere in the stack
 
=head1 DESCRIPTION
 
=head1 METHODS
 
This class defines the following methods.
 
=head2 call
 
Used by plack to call the middleware
 
=cut
 
1;

__END__

use Exporter 'import';
use Carp 'croak';
 
our @EXPORT_OK = qw(stash get_stash);
 
sub PSGI_KEY { 'Catalyst.Stash.v1' };
 
sub get_stash {
  my $env = shift;
  return $env->{&PSGI_KEY} ||
    _init_stash_in($env);
}
 
sub stash {
  my ($host, @args) = @_;
  return get_stash($host->env)
    ->(@args);
}
 
sub _create_stash {
  my $stash = shift || +{};
  return sub {
    if(@_) {
      my $new_stash = @_ > 1 ? {@_} : $_[0];
      croak('stash takes a hash or hashref')
        unless ref $new_stash;
      foreach my $key (keys %$new_stash) {
        $stash->{$key} = $new_stash->{$key};
      }
    }
    $stash;
  };
}
 
sub _init_stash_in {
  my ($env) = @_;
  return $env->{&PSGI_KEY} ||=
    _create_stash;
}

