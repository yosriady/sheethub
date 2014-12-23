$(document).on("page:change", function() {
    $(".alert").addClass("in");
    window.setTimeout(function() {
        $(".alert").slideUp(500, function(){
            $(this).remove();
        });
    }, 5000);
});
