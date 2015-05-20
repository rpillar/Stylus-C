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
            });
        },
        getValue : function() {
           return this.val;
        },
        getIndex : function() {
            return this.index;
        }
    }
    $(function() {
        var dd = new DropDown( $('#dd') );
        $(document).click(function() {
            // all dropdowns
            $('.wrapper-dropdown-3').removeClass('active');
        });
    });
