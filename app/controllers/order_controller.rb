class OrderController < ApplicationController
  def paypal_checkout
    sheet = Sheet.find(params[:sheet_id])
    options = {
      :ip                => request.env["REMOTE_ADDR"],
      :return_url        => order_new_url,
      :cancel_return_url => order_cancel_url,
      :currency          => "USD",
      :items             => [ { :name => "#{sheet.title}",
                                :number => "1",
                                :quantity => "1",
                                :amount   => sheet.price_cents,
                                :description => "#{sheet.title} | Sheethub",
                                :category => "Digital" } ]
    }
    response = PAYPAL_GATEWAY.setup_purchase(sheet.price_cents, options)
    if response.params["Errors"]
      errors_messages = response.params["Errors"].collect {|e| e["LongMessage"]}.to_sentence
      raise Exception.new("Paypal Checkout Error: #{errors_messages}")
    end
    # Need to do this?
    paypal_redirect_url = PAYPAL_GATEWAY.redirect_url_for(response.token).sub("https", "http")
    redirect_to paypal_redirect_url
  end

  def new
    binding.pry
    @order = Order.new(:paypal_token => params[:token])
    # a.k.a. Paypal’s return URL. i usually add a “Confirm Order” button in this action. it’s a good practice not to process the order right away.
  end

  def create
    #  create and purchase the order
    binding.pry
    @order = Order.build_order(order_params)
    if @order.save
      if @order.purchase # this is where we purchase the order. refer to the model method below
        redirect_to order_url(@order)
      else
        render :action => "failure"
      end
    else
      render :action => 'new'
    end
  end

  def cancel

  end

  def failure

  end

end
