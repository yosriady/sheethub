module Analytics
  extend self

  def tracker
    @tracker ||= Mixpanel::Tracker.new(Rails.application.secrets.mixpanel_token)

  end

  def track(user_id, event_name, data)
    # TODO: put on queue instead for better performance
    tracker.track(user_id, event_name, data)
  end

  def update_profile(user)
    tracker.people.set(user.id, {
      '$first_name'       => user.first_name,
      '$last_name'        => user.last_name,
      '$email'            => user.email,
      'paypal_email'      => user.paypal_email,
      'membership'        => user.membership_type,
      'username'          => user.username,
    });
  end
end