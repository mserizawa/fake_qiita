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

  def authorize_url!(params \\ []) do
    client()
    |> put_param(:scope, "read_qiita")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ [], options \\ []) do
    OAuth2.Client.get_token!(client(), params, List.insert_at(headers, -1, {"Content-Type", "application/json"}), options)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
