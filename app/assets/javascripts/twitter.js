var twttr;
$(document).on('page:change', function() {
  if (twttr) {
    twttr.widgets.load();
  }
});