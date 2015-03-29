class ContactFormController < ApplicationController
  def new
    track('Visited contact form')
    @contact = ContactForm.new(subject: params[:subject],
                               from: (current_user.email if user_signed_in?),
                               name: (current_user.display_name if user_signed_in?))
  end

  def create
    params[:contact_form][:to] = "yosriady@gmail.com"
    @contact = ContactForm.new(params[:contact_form])
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
