defmodule FakeQiita.Router do
  use FakeQiita.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FakeQiita do
    pipe_through :browser

    get "/", PageController, :index
    get "/entries.json", PageController, :select_entries
  end

  scope "/auth", FakeQiita do
    pipe_through :browser

    get "/", PageController, :auth
    get "/callback", PageController, :callback
    get "/logout", PageController, :logout
  end

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
