$(document).on("page:change", function() {

// Toggle Full width
$( '#toggle-canvas-btn' ).click(function() {
  var is_fullwidth = ($( '#toggle-canvas-btn' ).attr('fullwidth') === 'true');
  if (is_fullwidth){
    $('#sheet-content').removeClass('col-xs-12').addClass('col-xs-8');
    $('#sheet-sidebar').toggle();
    $(this).attr('fullwidth', 'false');
  } else {
    $('#sheet-content').removeClass('col-xs-8').addClass('col-xs-12');
    $('#sheet-sidebar').toggle();
    $(this).attr('fullwidth', 'true');
  }
  $(this).trigger('resizeEnd');
});

// Broadcast window resize event
$(window).resize(function() {
    if(this.resizeTO) clearTimeout(this.resizeTO);
    this.resizeTO = setTimeout(function() {
        $(this).trigger('resizeEnd');
    }, 100);
});

var pdfDoc = null,
      pageNum = 1,
      pageRendering = true,
      pageNumPending = null,
      canvas = document.getElementById('pdf-canvas');

/**
 * Get page info from document, resize canvas accordingly, and render page.
 * @param num Page number.
 */
function renderPage(num) {
  pageRendering = true;
  // Using promise to fetch the page
  pdfDoc.getPage(num).then(function(page) {
    var page_width = page.pageInfo.view[2];
    var page_height = page.pageInfo.view[3];
    var scale = $('#sheet-content').width() / page_width;
    var viewport = page.getViewport(scale);
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    // Render PDF page into canvas context
    var renderContext = {
      canvasContext: canvas.getContext('2d'),
      viewport: viewport
    };
    var renderTask = page.render(renderContext);

    // Wait for rendering to finish
    renderTask.promise.then(function () {
      pageRendering = false;
      if (pageNumPending !== null) {
        // New page rendering is pending
        renderPage(pageNumPending);
        pageNumPending = null;
      }
    });
  });

  // Update page counters
  _.each($('.pdf-canvas-page-num'), function(e){e.textContent = pageNum;});
}

$(window).bind('resizeEnd', function() {
  if(pdfDoc){
      renderPage(pageNum || 1);
  }
});

/**
 * If another page rendering in progress, waits until the rendering is
 * finised. Otherwise, executes rendering immediately.
 */
function queueRenderPage(num) {
  if (pageRendering) {
    pageNumPending = num;
  } else {
    renderPage(num);
    $('html, body').animate({scrollTop:$('#pdf-canvas').offset().top - 20}, 'slow');
  }
}

/**
 * Displays previous page.
 */
function onPrevPage() {
  var goingToFirstPage = ((pageNum - 1) == 1);
  if (goingToFirstPage) {
      $('.pdf-canvas-prev').addClass("disabled");
  }
  $('.pdf-canvas-next').removeClass("disabled");

  if (pageNum <= 1) {
    return;
  }

  pageNum--;
  queueRenderPage(pageNum);
}
_.each($('.pdf-canvas-prev'), function(btn){ btn.addEventListener('click', onPrevPage)});

/**
 * Displays next page.
 */
function onNextPage() {
  var goingToLastPage = ((pageNum + 1) == pdfDoc.numPages);
  if (goingToLastPage){
      $('.pdf-canvas-next').addClass("disabled");
  }
  $('.pdf-canvas-prev').removeClass("disabled");

  if (pageNum >= pdfDoc.numPages) {
    return;
  }

  pageNum++;
  queueRenderPage(pageNum);
}
_.each($('.pdf-canvas-next'), function(btn){ btn.addEventListener('click', onNextPage)});

/**
 * Asynchronously downloads PDF.
 */
function loadPDF(url){
PDFJS.getDocument(url).then(function (pdfDoc_) {
    pdfDoc = pdfDoc_;

    _.each($('.pdf-canvas-page-count'), function(e){e.textContent = pdfDoc.numPages;});
    if(pdfDoc.numPages > 1){
      $('.pdf-canvas-next').removeClass("disabled");
    }

    // Initial/first page rendering
    renderPage(pageNum);
  });
}

function showLoader(){
var canvas = document.getElementById("pdf-canvas");
var context = canvas.getContext("2d");
context.fillStyle = "#5cb85c";
context.font = '36px Roboto Slab';
var textString = "Loading...",
    textWidth = context.measureText(textString).width;
context.fillText(textString , (canvas.width/2) - (textWidth / 2), 150);
}

function initCanvas(){
canvas.height = window.innerHeight;
canvas.width = $("#sheet-content").width();
}

if(canvas && gon && gon.pdf_url){
initCanvas();
showLoader();
loadPDF(gon.pdf_url);
}
});