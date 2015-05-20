       // When the DOM is ready, initialize the scripts.
        jQuery(function( $ ){

            // Get a reference to the container.
            var container = $( "#helpcontainer" );


            // Bind the link to toggle the slide.
            $( "a#infolink" ).click(

                function( event ){
                    // Prevent the default event.
                    event.preventDefault();

                    // Toggle the slide based on its current
                    // visibility.
                    if (container.is( ":visible" )){

                        //$("#partials_info").mCustomScrollbar({
                        //    theme:"3d",
                        //    scrollInertia: 800,
                        //    scrollButtons: {
                        //        enable: true
                        //    }
                        //});
                        // Hide - slide up.
                        container.slideUp( 500 );

                    } else {

                        // Show - slide down.
                        container.slideDown( 500 );

                    }
                }
            );

        });
