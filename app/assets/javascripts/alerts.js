$(document).on("page:change", function() {
    $(".alert").addClass("in");
    window.setTimeout(function() {
        $(".alert").fadeTo(300, 0).slideUp(300, function(){
            $(this).remove();
        });
    }, 3000);
});
