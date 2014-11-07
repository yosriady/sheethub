$(document).on("page:change", function() {
    $("#paypal-checkout-btn").one('click',function(e){
        $("#paypal-checkout-btn button").addClass("disabled");
        $("#paypal-checkout-btn button").html("<i class='fa fa-spinner fa-spin'></i> Please wait while we redirect you to Paypal...")
        $('#modal-close-btn').remove();
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });
});