require 'argon2'

module Devise
  class Argon2Encryptor
    def self.digest(password)
      ::Argon2::Password.create(password)
    end

    def self.compare(encrypted_password, password)
      ::Argon2::Password.verify_password(password, encrypted_password)
    end
  end
end
