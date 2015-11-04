defmodule FakeQiita.PageController do
  use FakeQiita.Web, :controller

  def index(conn, %{"user_id" => user_id}) do
    user = ConCache.get_or_store(:qiita_cache, "#{user_id}_user", fn() ->
      select_user(user_id)
    end)

    unless user do
      json conn, %{error: "not found"}
    end

    render conn, "index.html", user: user
  end

  def select_entries(conn, %{"user_id" => user_id}) do
    entries = ConCache.get_or_store(:qiita_cache, "#{user_id}_entries", fn() ->
      request_entries([], user_id, 1)
    end)

    json conn, entries
  end

  defp select_user(user_id) do
    token = FakeQiita.Qiita.access_token()
    result = OAuth2.AccessToken.get!(token, "/items?per_page=1&query=user:#{user_id}")
    case result do
      %{status_code: 200, body: [item | _]} ->
        item["user"]
      _ ->
        nil
    end
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

  defp request_entries(entries, user_id, page) when length(entries) < (page - 1) * 100 do
    entries
  end

  defp request_entries(entries, user_id, page) do
    token = FakeQiita.Qiita.access_token()
    result = OAuth2.AccessToken.get!(token, "/items?page=#{page}&per_page=100&query=user:#{user_id}")
    case result do
      %{status_code: 200, body: body} ->
        parsed = body |> Enum.map(&(parse_entry(&1)))
        request_entries(entries ++ parsed, token, page + 1)
      _ ->
        nil
    end
  end

end
