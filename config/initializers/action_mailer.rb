# Use new AWS::SES mailer method from 'aws-ses' gem
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
    access_key_id: ENV['SES_KEY'],
    secret_access_key: ENV['SES_SECRET'],
    signature_version: 4
