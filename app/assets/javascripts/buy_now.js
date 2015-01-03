$(document).on("page:change", function() {
    $('#amount').maskMoney();
    $('.add_button').click(function(){
      $(this).addClass("animated rubberBand");
      var newAmount = parseFloat($('#amount').val()) + parseFloat($(this).data('amount'));
      $('#amount').val(newAmount.toFixed(2));
      $(this).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        $(this).removeClass("animated rubberBand");
      });
    })

    $("#buy-now").click(function(){
      $('#buyNowModal').addClass('animated bounceIn');
      $('#buyNowModal').modal();
    });

    // Client side min amount validation
    $( "#amount" ).change(function() {
      var currentAmount = parseFloat($('#amount').val());
      var min = parseFloat($('#amount').data("min"));
      if (currentAmount < min){
        $("#paypal-checkout-btn").addClass("disabled");
      } else {
        $("#paypal-checkout-btn").removeClass("disabled");
      }
    });
});