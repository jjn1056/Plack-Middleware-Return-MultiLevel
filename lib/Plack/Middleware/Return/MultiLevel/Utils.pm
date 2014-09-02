use strict;
use warnings;

package Plack::Middleware::Return::MultiLevel::Utils;

use Exporter 'import';
use Plack::Middleware::Return::MultiLevel;

our @EXPORT_OK = qw(return_to_level return_to_default_level);

sub return_to_level {
  my ($env, $level_name, @returning) = @_;
  return Plack::Middleware::Return::MultiLevel::_return(
    $env, $level_name, @returning);
}

sub return_to_default_level {
  my ($env, @returning) = @_;
  return Plack::Middleware::Return::MultiLevel::_return(
    $env, Plack::Middleware::Return::MultiLevel::DEFAULT_LEVEL_NAME, @returning);
}


=head1 TITLE
 
Plack::Middleware::Return::MultiLevel::Utils - Ease of Use Utility subroutines

=head1 SYNOPSIS

    TBD

=head1 DESCRIPTION

    TBD

=head1 EXPORTS

This class defines the following exportable subroutines

=head2 return_to_default_level

    TBD

=head2 return_to_level

    TBD
 
=head1 AUTHOR
 
See L<Plack::Middleware::Return::MultiLevel>

=head1 SEE ALSO

L<Plack::Middleware::Return::MultiLevel>
 
=head1 COPYRIGHT & LICENSE
 
See L<Plack::Middleware::Return::MultiLevel>

=cut

1;
