defmodule FakeQiita.PageController do
  use FakeQiita.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp parse_entry(entry) do
    url = entry["url"]
    %{body: html} = HTTPoison.get!(url)
    results = Floki.find(html, "span.js-stocksCount")
    {_, _, [stocks_string]} = List.first(results)
    {stocks, _} = Integer.parse(stocks_string)
    %{
        "created_at" => entry["created_at"],
        "url" => url,
        "tags" => entry["tags"],
        "title" => entry["title"],
        "stock_count" => stocks
    }
  end

  defp request_entries(entries, token, page) when length(entries) < (page - 1) * 100 do
    entries
  end

  defp request_entries(entries, token, page) do
    params = %{"page" => Integer.to_string(page), "per_page" => "100"}
    result = OAuth2.AccessToken.get!(token, "/authenticated_user/items", params)
    case result do
      %{status_code: 200, body: body} ->
        parsed = body |> Enum.map(&(parse_entry(&1)))
        request_entries(entries ++ parsed, token, page + 1)
      _ ->
        nil
    end
  end

  def select_entries(conn, _params) do
    token = get_session(conn, :access_token)
    unless token do
      json conn, %{"error" => "not authorized"}
    end
    user = get_session(conn, :current_user)

    entries = ConCache.get_or_store(:entries_cache, user["id"], fn() ->
        request_entries([], token, 1)
    end)

    json conn, entries
  end

  def auth(conn, _params) do
    redirect conn, external: FakeQiita.Qiita.authorize_url!
  end

  def callback(conn, %{"code" => code}) do
    token = FakeQiita.Qiita.get_token!(code: code)
    token = Map.put(token, :access_token, token.other_params["token"])
    %{body: user} = OAuth2.AccessToken.get!(token, "/authenticated_user")

    conn
      |> put_session(:current_user, user)
      |> put_session(:access_token, token)
      |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
      |> put_session(:current_user, nil)
      |> put_session(:access_token, nil)
      |> redirect(to: "/")
  end
end
