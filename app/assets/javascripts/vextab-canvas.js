$(document).on("page:change", function() {
    var DEFAULT_SCALE = 0.8;

    function calculateNoteCanvasWidth(){
        var window_width = $("#note-content").width();
        return window_width + 100;
    }

    function renderNote(scale, width){
        var scale = scale ? scale : DEFAULT_SCALE;
        var width = width ? width : calculateNoteCanvasWidth();

        var renderer = new Vex.Flow.Renderer($('#note-canvas')[0], Vex.Flow.Renderer.Backends.CANVAS);
        var artist = new Artist(10, 10, width, {scale: scale});
        var vextab = new VexTab(artist);

        vextab.reset();
        artist.reset();
        vextab.parse($("#note-body").val());
        artist.render(renderer);
    }

    renderNote();

    $(window).bind('resizeEnd', function() {
        console.log("Canvas resized!");
        renderNote();
    });

    $(window).resize(function() {
        if(this.resizeTO) clearTimeout(this.resizeTO);
        this.resizeTO = setTimeout(function() {
            $(this).trigger('resizeEnd');
        }, 500);
    });

});