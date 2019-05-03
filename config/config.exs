use Mix.Config

config :paperwork_service_users, Paperwork.Users.Server,
    adapter: Plug.Cowboy,
    plug: Paperwork.Users,
    scheme: :http,
    ip: {0,0,0,0},
    port: {:system, :integer, "PORT", 8881}

config :paperwork_service_users,
    maru_servers: [Paperwork.Users.Server]

config :paperwork, :server,
    app: :paperwork_service_users,
    cache_ttl_default: 86_400,
    cache_janitor_interval: 60,
    jwt_secret: {:system, :string, "JWT_SECRET", "ru4XngBQ/uXZX4o/dTjy3KieL7OHkqeKwGH9KhClVnfpEaRcpw+rNvvSiC66dyiY"}

config :paperwork, :mongodb,
    url: {:system, :string, "MONGODB_URL", "mongodb://localhost:27017/users"}

config :paperwork, :internal,
    cache_ttl: 60,
    configs: {:system, :string, "INTERNAL_RESOURCE_CONFIGS", "http://localhost:8880/internal/configs"},
    users:   {:system, :string, "INTERNAL_RESOURCE_USERS",   "http://localhost:8881/internal/users"},
    notes:   {:system, :string, "INTERNAL_RESOURCE_NOTES",   "http://localhost:8882/internal/notes"}

config :logger,
    backends: [:console],
    level: :debug
