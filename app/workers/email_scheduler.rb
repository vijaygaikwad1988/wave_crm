class EmailScheduler
    @queue = :email
    def self.perform(user_email_id, contact_id)
        puts "In schedulerrrrrrrrr"
       @notification = Notification.find(contact_id)
       NotificationMailer.new_notification(user_email_id, @notification.contact.email, @notification.body, "vivek").deliver

    end
end

