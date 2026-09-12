require "base64"
require "json"
require "openssl"

class JwtToken
  ALGORITHM = "HS256"
  def self.encode(payload, expires_in: 12.hours)
    data = payload.merge(exp: (Time.current + expires_in).to_i)
    header = { alg: ALGORITHM, typ: "JWT" }
    encoded_header = base64(header.to_json)
    encoded_payload = base64(data.to_json)
    signature = sign("#{encoded_header}.#{encoded_payload}")
    "#{encoded_header}.#{encoded_payload}.#{signature}"
  end

  def self.decode(token)
    header, payload, signature = token.to_s.split(".")
    return nil unless header && payload && signature && secure_compare(signature, sign("#{header}.#{payload}"))
    data = JSON.parse(Base64.urlsafe_decode64(pad(payload))).with_indifferent_access
    return nil if data[:exp].to_i < Time.current.to_i
    data
  rescue JSON::ParserError, ArgumentError
    nil
  end

  def self.base64(value) = Base64.urlsafe_encode64(value, padding: false)
  def self.sign(value) = Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", secret, value), padding: false)
  def self.secret = ENV.fetch("JWT_SECRET", Rails.application.secret_key_base)
  def self.pad(value) = value + ("=" * ((4 - value.length % 4) % 4))
  def self.secure_compare(a, b) = ActiveSupport::SecurityUtils.secure_compare(a, b)
  private_class_method :base64, :sign, :secret, :pad, :secure_compare
end
