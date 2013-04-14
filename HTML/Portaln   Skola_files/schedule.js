function changeDateBox(next){
    var monday = new Date($("#date_week").attr("monday"));
    var week = parseInt($("#date_week").html());
    if(next=='+'){
        monday.setDate(monday.getDate()+7);
        if(week==52){
            week = 1;
        }else{
            week = week + 1;
        }
    }else{
        monday.setDate(monday.getDate()-7);
        if(week==1){
            week = 52;
        }else{
            week = week-1;
        }
    }
    changeCalendarFront(monday,week);
    $(".date_box").each(function(index){
        var newhtml = '<div class="header">' + $(this).find(".header").html() + '</div>';
        $(this).css('background-image', 'url("/skola/img/design/loader.gif")').css('background-position','center center').css('background-repeat','no-repeat');
        thisday = new Date(monday)
        thisday.setDate(thisday.getDate()+index);
        loadInfoBox(thisday,this);
    })
}
function changeCalendarFront(monday,week){
    $("#date_year").html(monday.getFullYear());
    $("#date_week").html(week);
    var day = monday.getDate().toString();
    if(day.length==1){
        day = '0' + day;
    }
    var month = (monday.getMonth()+1).toString();
    if(month.length==1){
        month = '0' + month;
    }
    var newMonday = monday.getFullYear() + '-' + month + '-' + day;
    $("#date_week").attr("monday",newMonday);
    var sunday = new Date(monday);
    sunday.setDate(sunday.getDate()+6);
    var interval = monday.getDate() + '/' + (monday.getMonth()+1) + ' - ' + sunday.getDate() + '/' + (sunday.getMonth()+1);
    $("#date_period").html(interval);
}
function loadInfoBox(date,object){
    date = new Date(date);
    var day = date.getDate().toString();
    if(day.length==1){
        day = '0' + day;
    }
    var month = (date.getMonth()+1).toString();
    if(month.length==1){
        month = '0' + month;
    }
    var url = 'ladda/' + date.getFullYear() + month + day;
    $(object).load(url);
    $(object).css('background-image','none');
}