return if ENV["SECRET_KEY_BASE_DUMMY"]

if Rails.env.development?
  Rails.application.config.action_mailer.delivery_method = :letter_opener
elsif !Rails.env.test?
  Rails.application.config.action_mailer.delivery_method = :smtp
end

Rails.application.config.action_mailer.smtp_settings = {
  address:              Rails.application.config.email_address,
  port:                 Rails.application.config.email_port,
  domain:               Rails.application.config.email_domain,
  user_name:            Rails.application.config.email_user_name,
  password:             Rails.application.config.email_password,
  authentication:       Rails.application.config.email_authentication,
  enable_starttls_auto: Rails.application.config.email_enable_starttls_auto,
  openssl_verify_mode:  "none"
}
