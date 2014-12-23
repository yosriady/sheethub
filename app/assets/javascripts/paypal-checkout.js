$(document).on("page:change", function() {
    $("#paypal-checkout-btn").one('click',function(e){
        $("#paypal-checkout-btn").addClass("disabled");
        $("#paypal-checkout-btn").html("<em class='fa fa-spinner fa-spin'></em> Redirecting to PayPal...")
        $('#modal-close-btn').remove();
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });
});