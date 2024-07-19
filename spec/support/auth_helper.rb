# spec/scope/auth_helper.rb
module AuthHelper
  def auth_headers(user)
    jti = user.jti
    exp = Time.now.to_i + 4 * 3600
    payload = {
      user_id: user.id,
      jti: jti,
      sub: user.id,
      scp: 'user',
      exp: exp
    }
    
    token = JWT.encode(payload, Rails.application.credentials.secret_key_base)
    { 'Authorization' => "Bearer #{token}" }
  end
end
