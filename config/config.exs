use Mix.Config

config :paperwork, Paperwork.Server,
  adapter: Plug.Cowboy,
  plug: Paperwork,
  scheme: :http,
  port: 8880

config :paperwork,
  maru_servers: [Paperwork.Server]

config :paperwork, Auth.Guardian,
  issuer: "Paperwork",
  secret_key: "ru4XngBQ/uXZX4o/dTjy3KieL7OHkqeKwGH9KhClVnfpEaRcpw+rNvvSiC66dyiY", # mix guardian.gen.secret
  permissions: %{
    default: [:read_users, :write_users]
  }

config :paperwork, Auth.Plug.AccessPipeline.Authenticated,
  module: Auth.Guardian,
  error_handler: Auth.Plug.ErrorHandler

config :paperwork, Auth.Plug.AccessPipeline.Unauthenticated,
  module: Auth.Guardian,
  error_handler: Auth.Plug.ErrorHandler

config :logger,
  backends: [:console]
