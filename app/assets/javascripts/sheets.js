$(document).on("page:change", function() {
    $("#sheet-pdf-link").one('click',function(e){
        $("#sheet-pdf-link").addClass("disabled");
        $("#sheet-pdf-link .sheet-file p").html("<em class='fa fa-spinner fa-spin'></em> Downloading...")
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });
});