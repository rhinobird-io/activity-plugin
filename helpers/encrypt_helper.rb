require 'openssl'
require 'base64'

class EncryptHelper
  KEY = ENV['KEY'] || '123'
  def self.encrypt(message)
    digest = OpenSSL::Digest.new('sha1')
    OpenSSL::HMAC.hexdigest(digest, KEY, message)
  end
end