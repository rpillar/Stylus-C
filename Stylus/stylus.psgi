use strict;
use warnings;

use Stylus;

my $app = Stylus->apply_default_middlewares(Stylus->psgi_app);
$app;

