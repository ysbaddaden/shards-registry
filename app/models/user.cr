require "crypto/bcrypt"
require "secure_random"

class User < Frost::Record
  has_many :shards

  def before_create
    generate_api_key
  end

  def validate
    if name.blank?
      errors.add(:name, "name is required")
    elsif (name.to_s =~ /\A[a-zA-Z0-9_\-]+\Z/).nil?
      errors.add(:name, "name must only contain ASCII chars, digits, dashes or underscores")
    end

    if email.blank?
      errors.add(:email, "email is required")
    elsif !validate_uniqueness_of(:email)
      errors.add(:email, "email conflict")
    end

    if encrypted_password.nil?
      errors.add(:password, "password is required")
    end
  end

  # :nodoc:
  macro validate_uniqueness_of(attr_name)
    %test = self.class.where({ {{ attr_name }} => {{ attr_name.id }} })
    %test = %test.where("#{ self.class.primary_key } <> ?", id) if id
    !%test.any?
  end

  def self.find_for_database_authentication(name)
    find_by({ name: name })
  end

  def self.find_for_token_authentication(api_key)
    find_by({ api_key: api_key })
  end

  def password=(password : String)
    return if password.blank?
    self.encrypted_password = Crypto::Bcrypt::Password.create(password, cost: Frost.config.bcrypt_cost).to_s
  end

  def valid_password?(password)
    if password.is_a?(String) && (encrypted_password = @encrypted_password)
      Crypto::Bcrypt::Password.new(encrypted_password) == password
    else
      false
    end
  end

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64(32)
  end

  def serializable_hash
    {
      name: name,
      email: email,
      api_key: api_key,
      created_at: created_at,
      updated_at: updated_at,
    }
  end

  def to_param
    name
  end
end
