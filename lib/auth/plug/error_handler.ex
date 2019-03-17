defmodule Auth.Plug.ErrorHandler do
  use Paperwork.Server
  use Paperwork.Helpers.Response

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> resp({:unauthorized, %{status: 1, content: %{error: to_string(type)}}})
  end
end
