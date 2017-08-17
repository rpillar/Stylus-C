
#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use DDP;
use JSON;

my $dbfile = "./Stylus/stylus.db";
my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbfile","","" ) || die ;

my $process_line = 0;

my @file = <DATA>;
foreach ( @file  ) {
    if ( $process_line ) {
        $process_line = 0;
        my $html_string = process_partial( $_ );
        print $html_string;
        next;
    }

    if ( $_ !~ /^##########$|^==========$/ ) {
        print $_;
    }
    
    if ( $_ =~ /^##########$/ ) {
        $process_line = 1;
    }
    if ( $_ =~ /^==========$/ ) {
        next;
    }
}

sub process_partial {
    my $json_string = shift;

    my $hash = from_json( $json_string );
    my $html_string = "";

    # is this <content> ...
    if ( $hash->{ contentType } ) {

        # get id of <contentType>
        my $type = ucfirst($hash->{contentType});   
        my @values;
        push @values, $type;      
        my $sth = "SELECT id FROM content_type WHERE type = ?";       
        my $db_ref = $dbh->selectrow_hashref( $sth, undef ,@values );

        # get content 'ids' - ensures that we are able to access the data in the correct order
        @values = ();
        push @values, $db_ref->{id}; # content type
        push @values, 10;            # domain id
        push @values, 'y';           # publish flag - must be 'y'
        $sth = "SELECT id FROM content WHERE type_id = ? and domain_id = ? and publish = ?";
        my @content_ids = $dbh->selectall_array( $sth, undef ,@values );

        # get content from db ...
        $sth = "SELECT id, title, content, content_date FROM content WHERE type_id = ? and domain_id = ? and publish = ?";
        my $content = $dbh->selectall_hashref( $sth, 'id', undef ,@values );

        # get partial - into which the content will be inserted.
        @values = ();
        push @values, $hash->{partial};      
        $sth = "SELECT partial FROM partials WHERE name = ?";       
        $db_ref = $dbh->selectrow_hashref( $sth, undef ,@values );
        my $partial = $db_ref->{partial};
  
        # iterate over the content (using the partial text) to create the html_string  
        if ( $hash->{order} and $hash->{order} eq 'reverse' ) {
            @content_ids = reverse( @content_ids );           
        }  
        foreach my $id ( @content_ids ) {
            my $html = $partial;
            $html =~ s/\*\*\*\*\*\*\*\*\*\*/$content->{ $id->[0] }{ content }/;
            $html_string = $html_string . $html;           
        }
    }
    else {
        # get partial - into which the content will be inserted.
        my @values = ();
        push @values, $hash->{partial};            
        my $sth = "SELECT partial FROM partials WHERE name = ?";       
        my $db_ref = $dbh->selectrow_hashref( $sth, undef ,@values );
        my $html = $db_ref->{partial};
        $html_string = $html_string . $html;
    }

    return $html_string;
}

__END__
<html>
    <head>
       <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    </head>
    <body>
        <div class="jumbotron">
            <h1>Welcome</h1>
        </div>
        <div class="container">
##########
{ "partial": "articles", "contentType": "article", "number": 4 }
==========
        </div>
##########
{ "partial": "Footer" }
==========
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
    </body>
</html>