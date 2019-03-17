defmodule Auth.Plug.ErrorHandler do
  use Paperwork.Server
  use Paperwork.Helpers.Response

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> response_json(%{unauthorized: 2}, {:unauthorized, %{message: to_string(type)}})
  end
end
