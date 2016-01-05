require "openssl/md5"

abstract class ApplicationView < Frost::View
  def has_error?(record, attr_name)
    if errors = record.errors[attr_name]?
      return errors.any?
    end

    false
  end

  def error_message(record, attr_name)
    if errors = record.errors[attr_name]?
      errors.first?
    end
  end

  def accessible?(record)
    case record
    when Shard
      record.user_id == current_user?.try(&.id)
    when User
      record == current_user?
    else
      false
    end
  end

  def gravatar_url(email, size = 100, default = "identicon")
    hash = OpenSSL::MD5.hash(email.to_s.downcase).to_slice.hexstring
    "https://secure.gravatar.com/avatar/#{ hash }.jpg?s=#{ size }&d=#{ default }"
  end

  def osi_license_url(license)
    if license.starts_with?("http://") || license.starts_with?("https://")
      license
    else
      "http://opensource.org/licenses/#{ license }"
    end
  end
end
