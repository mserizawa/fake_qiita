defmodule FakeQiita.Qiita do
  use OAuth2.Strategy

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET"),
      redirect_uri: "http://localhost:4000/auth/callback",
      site: "http://qiita.com/api/v2",
      authorize_url: "http://qiita.com/api/v2/oauth/authorize",
      token_url: "http://qiita.com/api/v2/access_tokens"
    ])
  end

  def access_token do
    OAuth2.AccessToken.new(System.get_env("ACCESS_TOKEN"), client())
  end
end
