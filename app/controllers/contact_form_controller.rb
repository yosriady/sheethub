class ContactFormController < ApplicationController

  def new
    @contact = ContactForm.new
  end

  def create
    @contact = ContactForm.new(params[:contact_form])
    binding.pry
    @contact.request = request
    if @contact.deliver
      flash.now[:notice] = 'Thank you for your message. We will contact you soon!'
    else
      flash.now[:error] = 'Cannot send message.'
      render :new
    end
  end

end
