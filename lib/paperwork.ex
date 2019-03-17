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

  # rescue_from Unauthorized, as: e do
  #   IO.inspect(e)

  #   conn
  #   |> put_status(401)
  #   |> text("Unauthorized")
  # end

  rescue_from [MatchError, RuntimeError], with: :custom_error
  rescue_from Maru.Exceptions.InvalidFormat, as: e do
    IO.inspect(e)

    conn
    |> response_json(%{badrequest: 0}, {:badrequest, %{param: e.param, reason: e.reason}})
  end

  rescue_from :all, as: e do
    IO.inspect e

    conn
    |> put_status(Plug.Exception.status(e))
    |> text("Server Error")
  end

  defp custom_error(conn, exception) do
    conn
    |> put_status(500)
    |> text(exception.message)
  end
end
