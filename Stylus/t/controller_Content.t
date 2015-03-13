use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Stylus';
use Stylus::Controller::Content;

ok( request('/stylus/content')->is_success, 'Request should succeed' );
done_testing();
