$(document).on("page:change", function() {
    var DEFAULT_SCALE = 1.0;
    var NOTE_CANVAS = $('#note-canvas');

    function calculateNoteCanvasWidth(width){
        var window_width = width || $("#note-content").width();
        return 0.95 * window_width;
    }

    function renderNote(scale, width){
        NOTE_CANVAS.empty();
        var scale = scale ? scale : DEFAULT_SCALE;
        var width = width ? width : calculateNoteCanvasWidth();

        var renderer = new Vex.Flow.Renderer(NOTE_CANVAS[0], Vex.Flow.Renderer.Backends.RAPHAEL);
        var artist = new Artist(10, 10, width, {scale: scale});
        var vextab = new VexTab(artist);

        vextab.reset();
        artist.reset();
        vextab.parse($("#note_body").val());
        artist.render(renderer);
    }

    renderNote();

    $(window).bind('resizeEnd', function() {
        renderNote();
    });

    // Broadcast Window Resize event
    $(window).resize(function() {
        if(this.resizeTO) clearTimeout(this.resizeTO);
        this.resizeTO = setTimeout(function() {
            $(this).trigger('resizeEnd');
        }, 100);
    });
});