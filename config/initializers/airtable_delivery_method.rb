require Rails.root.join("lib/mail/airtable_delivery_method")

ActionMailer::Base.add_delivery_method :airtable_delivery_method, AirtableDeliveryMethod
