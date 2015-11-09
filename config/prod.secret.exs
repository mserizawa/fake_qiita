use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :fake_qiita, FakeQiita.Endpoint,
  secret_key_base: "AvYWOVPF1C4cjKA9cUUpNt6f2V8IEOQ7tCNUH6yOvufDBHNf+QcgLgZpqoabGMcz"

# Configure your database
config :fake_qiita, FakeQiita.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "fake_qiita_prod",
  pool_size: 20
