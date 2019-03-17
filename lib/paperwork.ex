defmodule Paperwork do
  use Paperwork.Server
  use Paperwork.Helpers.Response
  # use Maru.Router #, make_plug: true

  before do
    plug Plug.Logger
    plug Corsica, origins: "*"
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Jason,
      parsers: [:urlencoded, :json, :multipart]
  end
  resources do
    get do
      json(conn, %{hello: :world})
    end

    mount Paperwork.Users
    mount Paperwork.Registration
  end

  rescue_from Unauthorized, as: e do
    IO.inspect(e)

    conn
    |> resp({:unauthorized, %{status: 1, content: e}})
  end

  rescue_from [MatchError, RuntimeError], as: e do
    IO.inspect e

    conn
    |> resp({:error, %{status: 1, content: e}})
  end

  rescue_from Maru.Exceptions.InvalidFormat, as: e do
    IO.inspect e

    conn
    |> resp({:badrequest, %{status: 1, content: %{param: e.param, reason: e.reason}}})
  end

  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> resp({:error, %{status: 1, content: e}})
  end
end
