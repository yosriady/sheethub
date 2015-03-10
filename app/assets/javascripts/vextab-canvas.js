var Note = (function(){
    var DEFAULT_SCALE = 1.0;
    var DEFAULT_CANVAS_ELEMENT = $('#note-canvas');
    var DEFAULT_BODY_ELEMENT = $("#note_body");

    function calculateNoteCanvasWidth(width){
        var window_width = width || $("#note-content").width();
        return 0.95 * window_width;
    }

    function render(scale, width){
        $('#note-canvas').empty();
        var scale = scale ? scale : DEFAULT_SCALE;
        var width = width ? width : calculateNoteCanvasWidth();

        var renderer = new Vex.Flow.Renderer($('#note-canvas')[0], Vex.Flow.Renderer.Backends.RAPHAEL);
        var artist = new Artist(10, 10, width, {scale: scale});
        var vextab = new VexTab(artist);

        vextab.reset();
        artist.reset();
        vextab.parse($("#note_body").val());
        artist.render(renderer);
    }

    return {
        render: render
    }
})();

$(document).on("page:change", function() {
    if ($('#note-canvas').size() > 0){
        Note.render();

        $(window).bind('resizeEnd', function() {
            Note.render();
        });
    };

    // Broadcast Window Resize event
    $(window).resize(function() {
        if(this.resizeTO) clearTimeout(this.resizeTO);
        this.resizeTO = setTimeout(function() {
            $(this).trigger('resizeEnd');
        }, 100);
    });
});