$(document).on("page:change", function() {
    $("#paypal-checkout-btn").one('click',function(e){
        $("#paypal-checkout-btn").addClass("disabled");
        $("#paypal-checkout-btn").html("<em class='fa fa-spinner fa-spin'></em> Please wait while we redirect you to Paypal...")
        $('#modal-close-btn').remove();
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });
});