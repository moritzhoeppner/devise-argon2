module Devise
  module Models
    module Argon2
      def valid_password?(password)
        Devise::Argon2Encryptor.compare(encrypted_password, password)
      end

      protected

      def password_digest(password)
        Devise::Argon2Encryptor.digest(password)
      end
    end
  end
end