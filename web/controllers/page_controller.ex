defmodule FakeQiita.PageController do
  use FakeQiita.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def select_user(conn, %{"user_id" => user_id}) do
    user = ConCache.get_or_store(:qiita_cache, "#{user_id}_user", fn() ->
      request_user(user_id)
    end)

    case user do
      {:ok, value} ->
        render conn, "user.html", user: value
      {:not_found, []} ->
        render conn, "404.html"
      {:server_error, []} ->
        render conn, "500.html"
    end
  end

  def select_entries(conn, %{"user_id" => user_id}) do
    entries = ConCache.get_or_store(:qiita_cache, "#{user_id}_entries", fn() ->
      request_entries([], user_id, 1)
    end)

    json conn, entries
  end

  defp request_user(user_id) do
    token = FakeQiita.Qiita.access_token()
    result = OAuth2.AccessToken.get!(token, "/items?per_page=1&query=user:#{user_id}")
    case result do
      %{status_code: 200, body: [item | _]} ->
        {:ok, item["user"]}
      %{status_code: 200, body: []} ->
        {:not_found, []}
      _ ->
        {:server_error, []}
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
        parsed = body
        |> Enum.map(&Task.async(fn -> parse_entry(&1) end))
        |> Enum.map(&Task.await(&1, 5_000))
        request_entries(entries ++ parsed, user_id, page + 1)
      _ ->
        nil
    end
  end

end
