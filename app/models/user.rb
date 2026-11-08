class User < ApplicationRecord
    has_secure_token :api_token
    has_secure_password

    has_many :orders, dependent: :restrict_with_exception

    before_validation :normalize_email

    validates :name, presence: true
    validates :email, presence: true, uniqueness: { case_sensitive: false },
      format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
    validates :password, length: { minimum: 6 }, allow_nil: true

    private

    def normalize_email
        self.email = email.to_s.strip.downcase
    end
end
