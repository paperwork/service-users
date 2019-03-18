require Logger

defmodule Unauthorized do
  defexception message: "Unauthorized", plug_status: 401
end

defmodule Paperwork.Auth.Plug.SessionLoader do
  import Plug.Conn

  def init(options), do: options

  def call(%Plug.Conn{}=conn, _opts) do
    case get_req_header(conn, "authorization") |> Enum.at(0, "{}") |> Jason.decode! |> process_token do
      {:ok, user} -> conn |> put_private(:paperwork_user, user)
      _ -> raise Unauthorized
    end
  end

  defp process_token(%{"typ" => "access", "sub" => user_id} = _decoded_token) do
    case BSON.ObjectId.decode!(user_id) |> Paperwork.Collections.User.show do
      {:ok, user} -> {:ok, Map.from_struct(user)}
      other -> other
    end
  end

  defp process_token(other) do
      Logger.error("No valid access token: #{inspect(other)}")
      {:error, nil}
  end
end
