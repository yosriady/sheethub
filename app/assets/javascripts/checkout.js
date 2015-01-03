$(document).on("page:change", function() {
    var sheet_slug = window.location.href.substr(window.location.href.lastIndexOf('/') + 1);
    var min = parseFloat($('#amount').data("min"));

    $('#amount').maskMoney();
    $("#buy-now").click(function(){
      $('#buyNowModal').addClass('animated bounceIn');
      $('#buyNowModal').modal();
    });

    // Add buttons logic
    $('.add_button').click(function(){
      $(this).addClass("animated rubberBand");
      var newAmount = parseFloat($('#amount').val()) + parseFloat($(this).data('amount'));
      $('#amount').val(newAmount.toFixed(2));
      validateAboveMinimum(newAmount);
      updateCheckoutUrl(newAmount);
      $(this).one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
        $(this).removeClass("animated rubberBand");
      });
    })

    // Client side amount validation
    $( "#amount" ).change(function() {
      var currentAmount = parseFloat($('#amount').val());
      validateAboveMinimum(currentAmount);
      updateCheckoutUrl(currentAmount);
    });

    $("#paypal-checkout-btn").one('click',function(e){
        $("#paypal-checkout-btn").addClass("disabled");
        $("#paypal-checkout-btn").html("<em class='fa fa-spinner fa-spin'></em> Redirecting to PayPal...")
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });

    // Helper methods
    function updateCheckoutUrl(amount){
      var url = checkoutUrl(amount)
      console.log(url);
      $('#paypal-checkout-btn').attr('href', url);
    };

    function validateAboveMinimum(amount){
      if (amount < min){
        $("#paypal-checkout-btn").addClass("disabled");
      } else {
        $("#paypal-checkout-btn").removeClass("disabled");
      }
    };

    function checkoutUrl(amount){
      return window.location.origin + "/checkout?sheet=" + sheet_slug + "&amount=" + amount;
    }
});