use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Stylus';
use Stylus::Controller::Articles;

ok( request('/articles')->is_success, 'Request should succeed' );
done_testing();
