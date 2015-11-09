defmodule FakeQiita.Router do
  use FakeQiita.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FakeQiita do
    pipe_through :browser

    get "/", PageController, :index
    get "/:user_id", PageController, :select_user
    get "/:user_id/entries.json", PageController, :select_entries
  end
end
