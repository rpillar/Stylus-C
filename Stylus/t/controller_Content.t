use strict;
use warnings;
use Test::More;

use lib '../lib/Stylus';

use ok "Test::WWW::Mechanize::Catalyst" => "Stylus";

use Catalyst::Test 'Stylus';
use Stylus::Controller::Content;

# create 'user agent'
my $ua = Test::WWW::Mechanize::Catalyst->new;

# login
$ua->get_ok('http://localhost/stylus/login?username=rp2&password=1234', "Login 'test01'");

ok( request('/stylus/content')->is_success, 'Request should succeed' );
done_testing();
