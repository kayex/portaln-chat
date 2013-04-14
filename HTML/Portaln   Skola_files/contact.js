$(document).ready(function(){
    $("#contactSubmitButton").click(function(event){
        event.preventDefault();
        var $form = $("#contactForm"),
        $inputs = $form.find("input, select, button, textarea"),
        serializedData = $form.serialize();
        $inputs.attr("disabled", "disabled");
        $.ajax({
            url: "skicka/",
            type: "post",
            data: serializedData,
            success: function(response, textStatus, jqXHR){
                if(response=="1"){
                    alert('Meddelandet har skickats! Vi återkommer till dig så snart som möjligt.')
                    $inputs.removeAttr("disabled");
                }else if(response=="3"){
                    alert('Inget fält kan vara tomt!');
                    $inputs.removeAttr("disabled");
                }else if(response=="4"){
                    alert('Ogiltig e-postadress!');
                    $inputs.removeAttr("disabled");
                }else{
                    alert('Ett fel uppstod, försök igen!');
                    alert(response);
                    $inputs.removeAttr("disabled");
                }
            },
            error: function(jqXHR, textStatus, errorThrown){
                alert("Ett fel uppstod!\n" + errorThrown);
            },
            complete: function(){
                //$inputs.removeAttr("disabled");
            }
        });
    })
})