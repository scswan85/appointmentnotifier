class Appointment < ApplicationRecord
  validates :name, presence: true
  validates :phone_number, presence: true
  validates :time, presence: true

  after_create :reminder

  def reminder
    @twilio_number = Rails.application.credentials.twilio_number
    account_sid = Rails.application.credentials.twilio_sid
    @client = Twilio::Rest::Client.net account_sid, Rails.application.credentials.twilio_auth
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d %Y")
    reminder = "#{self.name}, this is a reminder of your appointment at #{time_str}."
    message = @client.api.account(account_sid).messages.create(
      from: @twilio_number,
      to: self.phone_number,
      body: reminder,
      )
  end

  def when_to_run
    minutes_before_appointment = 30.minutes
    time - minutes_before_appointment
  end
    
  handle_asynchronously :reminder, run_at: Proc.new { |i| i.when_to_run }
end
