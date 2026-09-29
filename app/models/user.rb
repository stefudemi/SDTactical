class User < ApplicationRecord
    has_secure_password

    has_many :orders, dependent: :restrict_with_exception

    before_validation :normalize_email

    validates :email, presence: true, uniqueness: { case_sensitive: false }

    private

    def normalize_email
        self.email = email.to_s.strip.downcase
    end
end
