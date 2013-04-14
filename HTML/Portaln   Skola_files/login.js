$(document).ready(function(){
    $("#loginFormButton").click(function(){
        submitLogin();
    })
    $("#loginFormPass").keyup(function(event){
        if(event.which==13){
            submitLogin();
        }
    })
})
function submitLogin(){
    var $form = $("#login"),
    $inputs = $form.find("input, select, button, textarea"),
    serializedData = $form.serialize();
    $inputs.attr("disabled", "disabled");
    $.ajax({
        url: "loggain/",
        type: "post",
        data: serializedData,
        success: function(response, textStatus, jqXHR){
            response = response.toString();
            if(response=="0"){
                $inputs.removeAttr("disabled");
                $("#loginFormError").slideDown();
                $("#loginFormError").effect("shake", { times:2,distance:10}, 500);
            }else{
                location.reload();
            }
        },
        error: function(jqXHR, textStatus, errorThrown){
            alert("Ett fel uppstod!\n" + errorThrown);
            $inputs.removeAttr("disabled");
        },
        complete: function(){
            //$inputs.removeAttr("disabled");
        }
    });
}