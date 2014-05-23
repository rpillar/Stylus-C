use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Stylus';
use Stylus::Controller::Create;

ok( request('/create')->is_success, 'Request should succeed' );
done_testing();
