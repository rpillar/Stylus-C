use strict;
use warnings;
use lib './lib';

use Stylus;

my $app = Stylus->apply_default_middlewares(Stylus->psgi_app);
$app;

