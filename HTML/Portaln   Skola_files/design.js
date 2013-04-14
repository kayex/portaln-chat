$(document).ready(function(){
    
    /* ----------------
    *       INIT
    * ---------------*/
    
    /* Set Main Menu with to the ul with +12 so the menu newer line wrap */
    $('div#mainMenu').css('width', $('div#mainMenu ul').eq(0).width() + 14);
    resizeBar(0);
    
    /* ----------------
    *     LISTENERS
    * ---------------*/
    
    /* All text/password boxes */
    $('input[type="text"], input[type="password"]').each(function(){
        
        $(this).focus(function(){
           if(this.value == $(this).attr('title')){
                this.value = '';
                $(this).removeClass('blurred');
           }
        });
        
        $(this).blur(function(){
           if(this.value == ''){
                $(this).addClass('blurred');
                this.value = $(this).attr('title');
           }
        });
        
        $(this).blur();
    });
    
    /* Links that leads nowhere */
    $('a[href="nolink"]').each(function(){
        $(this).click(function( event ){
            event.preventDefault();
        });
    });
    
    /* On wrapper resize (jquery-ba-resize)*/
    $('#wrapper').resize(function(){
        resizeBar(100);
    });
    
    /* Animate drop down menus */
    $('#bar #mainMenu ul li').each(function() {
        if($(this).children().length > 1){
            $(this).hover(function() {
                $(this).children().eq(1).slideToggle(100, 'linear');
            });
        }
    });
    
    /* ----------------
    *    FUNCTIONS
    * ---------------*/
    
    function resizeBar( dur ) {
        var $searchDD = $('#spotlight ul');
        var width = $('#spotlight #searchBox').width() + 10;
        $searchDD.animate({width: width + "px"}, dur, "linear");
    };
})(jQuery);