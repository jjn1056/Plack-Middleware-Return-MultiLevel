use Test::Most;
use Plack::Test;
use Plack::Request;
use Plack::Middleware::Return::MultiLevel;
use HTTP::Request::Common;

my $app = Plack::Middleware::Return::MultiLevel->wrap(sub {
  my $req = Plack::Request->new(shift);

  if($req->path eq '/') {
    ok $req->env->{Plack::Middleware::Return::MultiLevel->env_key};
    return [200, ['Content-Type', 'text/plain'], ['Hello']];
  }

  if($req->path eq '/seethis') {
    ok $req->env->{Plack::Middleware::Return::MultiLevel->env_key}
     ->([200, ['Content-Type', 'text/plain'], ['See this']]);

    return [200, ['Content-Type', 'text/plain'], ['Never see this']];
  }

  if($req->path eq '/intercepted') {

    return Plack::Middleware::Return::MultiLevel->wrap(sub{
      ok $req->env->{Plack::Middleware::Return::MultiLevel->env_key('area52')}
       ->([200, ['Content-Type', 'text/plain'], ['area52']]);
    }, level_name=>'area52')->($req->env);

    return [200, ['Content-Type', 'text/plain'], ['Never see this']];
  }

  if($req->path eq '/as_instance') {

    my $mw = Plack::Middleware::Return::MultiLevel->new(level_name=>'theisland');
    my $app = $mw->wrap(sub {
      my $env = shift;
      return $mv->returns($env
    });

    return Plack::Middleware::Return::MultiLevel->wrap(sub{
      ok $req->env->{Plack::Middleware::Return::MultiLevel->env_key('area52')}
       ->([200, ['Content-Type', 'text/plain'], ['area52']]);
    }, level_name=>'area52')->($req->env);

    return [200, ['Content-Type', 'text/plain'], ['Never see this']];
  }

});


test_psgi $app, sub {
    my $cb  = shift;

    {
      my $res = $cb->(GET "/");
      is $res->content, "Hello";
    }

    {
      my $res = $cb->(GET "/seethis");
      is $res->content, "See this";
    }

    {
      my $res = $cb->(GET "/intercepted");
      is $res->content, "area52";
    }

};

done_testing;


__END__

use Plack::Middleware::Return::MultiLevel 'return';

$req->returns($level, $res);
$req->returns($res); # do default level

returns($env, $level, $res);
returns($env, $res);

