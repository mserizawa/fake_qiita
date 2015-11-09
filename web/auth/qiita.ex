defmodule FakeQiita.Qiita do
  use OAuth2.Strategy

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET"),
      site: "http://qiita.com/api/v2"
    ])
  end

  def access_token do
    OAuth2.AccessToken.new(System.get_env("ACCESS_TOKEN"), client())
  end
end
