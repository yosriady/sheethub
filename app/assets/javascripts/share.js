$(document).on("page:change", function() {
    $('a[data-popup]').click(function(e) {
        var left = (screen.width/2)-(400/2);
        var top = (screen.height/2)-(400/2);
        window.open( $(this).attr('href'), "Popup", 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, height=400, width=400, top='+top+', left='+left );
        e.preventDefault();
    });
});