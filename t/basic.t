use Test::Most;
use Plack::Test;
use Plack::Request;
use Plack::Middleware::Return::MultiLevel;
use HTTP::Request::Common;

my $app = Plack::Middleware::Return::MultiLevel->wrap(sub {
  my $req = Plack::Request->new(shift);

  if($req->path eq '/') {
    ok $req->env->{&Plack::Middleware::Return::MultiLevel->PSGI_KEY};
    return [200, ['Content-Type', 'text/plain'], ['Hello']];
  }

  if($req->path eq '/seethis') {
    ok $req->env->{&Plack::Middleware::Return::MultiLevel->PSGI_KEY}
     ->([200, ['Content-Type', 'text/plain'], ['See this']]);

    return [200, ['Content-Type', 'text/plain'], ['Never see this']];
  }

  if($req->path eq '/intercepted') {

    return Plack::Middleware::Return::MultiLevel->wrap(sub{
      
    }, level_name=>'area52')->($req->env);

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
      my $res = $cb->(GET "/seethis");
      is $res->content, "See this";
    }

};

done_testing;
