use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Stylus';
use Stylus::Controller::Settings;

ok( request('/stylus/settings')->is_success, 'Request should succeed' );
done_testing();
