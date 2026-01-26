module Audits1984
  class AuditorToken < Console1984::Base
    EXPIRATION_PERIOD = 1.week

    belongs_to :auditor, class_name: Audits1984.auditor_class

    validates :token_digest, presence: true, uniqueness: true
    validates :expires_at, presence: true

    scope :active, -> { where("expires_at > ?", Time.current) }

    class << self
      def generate_for(auditor)
        plaintext_token = SecureRandom.base58(24)

        transaction do
          where(auditor: auditor).delete_all
          create!(
            auditor: auditor,
            token_digest: digest(plaintext_token),
            expires_at: EXPIRATION_PERIOD.from_now
          )
        end

        plaintext_token
      end

      def find_by_token(plaintext_token)
        return nil if plaintext_token.blank?

        active.find_by(token_digest: digest(plaintext_token))
      end

      private
        def digest(plaintext)
          Digest::SHA256.hexdigest(plaintext)
        end
    end

    def expired?
      expires_at <= Time.current
    end
  end
end
