<!-- dropdown code -->
    function DropDown(el) {
        this.dd = el;
        this.placeholder = this.dd.children('span');
        this.spanholder  = this.dd.find('span');
        this.opts = this.dd.find('ul.dropdown > li');
        this.val = '';
        this.id  = 'test';
        this.index = -1;
        this.initEvents();
    }
    DropDown.prototype = {
        initEvents : function() {
            var obj = this;

            obj.dd.on('click', function(event){
               $(this).toggleClass('active');
               return false;
            });

            obj.opts.on('click',function(){
                var opt = $(this);
                obj.val = opt.text();
                obj.myId  = opt.attr('data-id');
                obj.index = opt.index();
                obj.placeholder.text(obj.val);
                obj.spanholder.attr('data-id', obj.myId);
                checkPagesData(obj.myId);
            });
        },
        getValue : function() {
           return this.val;
        },
        getIndex : function() {
            return this.index;
        }
    }
    var checkPagesData = function(myId) {
        console.log('Clicked - inside function. My id is : ' + myId);

        var formData = {
            domain_id: myId
        };
        var pages_url = '/stylus/settings/pages_path/' + myId;
        console.log('call url : ' + pages_url);
        $.ajax({
            url: pages_url,
            type: 'GET',
            data: formData,
            dataType: 'json',
            success: function(data,status) {
                if ( data.path ) {
                    console.log('processed click ...');
                    $('#pages-actions').removeClass('pages-delete-hide');
                    $('div#pages-actions').addClass('pages-delete-show');
                    $('#new-pages-path').val( data.path );
                }
                else {
                    $('#new-pages-path').val( '' );
                    $('#pages-actions').removeClass('pages-delete-show');
                    $('div#pages-actions').addClass('pages-delete-hide');
                }
            },
            error: function(jqXHR,status,error) {
                notifyProcess( 'ERROR', 'A problem has occurred - please try again in a few minutes or contact us.', 'error' );
            }
        });

        // check if this id has a 'pages path' ...
    };
    $(function() {
        var dd = new DropDown( $('#dd') );
        $(document).click(function() {
            // all dropdowns
            $('.wrapper-dropdown-3').removeClass('active');
        });
    });
