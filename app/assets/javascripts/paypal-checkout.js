$(document).on("page:change", function() {
    $("#paypal-checkout-btn").one('click',function(e){
        $("#paypal-checkout-btn button").addClass("disabled");
        $("#paypal-checkout-btn button").text("Please wait while we redirect you to Paypal...")
        $('#modal-close-btn').remove();
        $('#loading-content').removeClass("hidden");
        $(this).on('click',function(ev){
          ev.preventDefault();
          return false;
        });
    });
});