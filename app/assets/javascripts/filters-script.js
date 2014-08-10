$(document).on("page:change", function() {
    $("#filter-toggle").click(function(e) {
      e.preventDefault();
      $("#wrapper").toggleClass("toggled");
    });
});