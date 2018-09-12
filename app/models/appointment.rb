class Appointment < ApplicationRecord
  validates :name, presence: true
  validates :phone_number, presence: true
  validates :time, presence: true

  after_create :new_reminder
  after_update :update_reminder
  after_destroy :destroy_reminder

  def new_reminder
    twilio_number = Rails.application.credentials.twilio_number
    account_sid = Rails.application.credentials.twilio_sid
    client = Twilio::REST::Client.new account_sid, Rails.application.credentials.twilio_auth
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d %Y")
    reminder = "#{self.name}, this is a reminder of your appointment at #{time_str}."
    message = client.messages.create(
      from: twilio_number,
      to: self.phone_number,
      body: reminder,
      )
  end


  def update_reminder
    twilio_number = Rails.application.credentials.twilio_number
    account_sid = Rails.application.credentials.twilio_sid
    client = Twilio::REST::Client.new account_sid, Rails.application.credentials.twilio_auth
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d %Y")
    reminder = "#{self.name}, this is to let you know your appointment was updated to #{time_str}. If you believe this was done in error, please contact us at ###-###-####."
    message = client.messages.create(
      from: twilio_number,
      to: self.phone_number,
      body: reminder,
      )
  end

  
  def destroy_reminder
    twilio_number = Rails.application.credentials.twilio_number
    account_sid = Rails.application.credentials.twilio_sid
    client = Twilio::REST::Client.new account_sid, Rails.application.credentials.twilio_auth
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d %Y")
    reminder = "#{self.name}, this is to let you know your appointment on #{time_str} has been cancelled. If you believe this was done in error, please contact us at ###-###-####."
    message = client.messages.create(
      from: twilio_number,
      to: self.phone_number,
      body: reminder,
      )
  end
end
