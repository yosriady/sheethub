class ContactFormController < ApplicationController
  def new
    track('Visited contact form')
    @contact = ContactForm.new
  end

  def create
    @contact = ContactForm.new(params[:contact_form])
    @contact.request = request
    if @contact.deliver
      flash[:notice] = 'Thank you for your message. We will contact you soon!'
      track('Submitted contact form')
      redirect_to root_url
    else
      flash.now[:error] = @contact.errors.full_messages.to_sentence
      render :new
    end
  end
end
