$(document).on("page:change", function() {
    $(".btn-omniauth").click(function(e){
        $(".btn-omniauth").addClass('disabled');
    });

});