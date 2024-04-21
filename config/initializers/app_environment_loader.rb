# frozen_string_literal: true

return if ENV["SECRET_KEY_BASE_DUMMY"]

class AppEnvironmentLoader
  def self.get(key, required:, default: nil)
    required ? ENV.fetch(key) : ENV.fetch(key, default)
  end

  def self.to_bool(val)
    ActiveModel::Type::Boolean.new.cast(val)
  end

  def self.prod?
    Rails.env.production?
  end

  def self.run
    Rails.application.config.tap do |c|
      # Email settings
      c.email_user_name = get("EMAIL_USER", required: prod?, default: "")
      c.email_password = get("EMAIL_PASSWORD", required: prod?, default: "")
      c.email_address = get("EMAIL_ADDRESS", required: prod?, default: "localhost")
      c.email_port = get("EMAIL_PORT", required: prod?, default: "25")
      c.email_domain = get("EMAIL_DOMAIN", required: prod?, default: "localhost")
      c.email_enable_starttls_auto = to_bool(get("EMAIL_AUTOTLS", required: prod?))
      c.email_authentication = get("EMAIL_AUTH", required: prod?)
    end
  end
end

AppEnvironmentLoader.run
