$(document).on("ready", function() {
    $("#filter-toggle").click(function(e) {
      e.preventDefault();
      $("#wrapper").toggleClass("toggled");
    });
});