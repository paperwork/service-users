defmodule Paperwork.Helpers.Response do
    defmacro __using__(_) do
        quote do
            import unquote(__MODULE__)
            import Plug.Conn
        end
    end

    def resp(%Plug.Conn{}=conn, {http_status, %{status: status, content: content}}) do
      case http_status do
        :ok           -> conn |> Plug.Conn.put_status(200) |> resp_json(status, content)
        :badrequest   -> conn |> Plug.Conn.put_status(400) |> resp_json(status, content)
        :unauthorized -> conn |> Plug.Conn.put_status(401) |> resp_json(status, content)
        :notfound     -> conn |> Plug.Conn.put_status(404) |> resp_json(status, content)
        :error        -> conn |> Plug.Conn.put_status(500) |> resp_json(status, content)
        other         -> conn |> Plug.Conn.put_status(500) |> resp_json(500, other)
      end
    end

    def resp(%Plug.Conn{}=conn, {:ok, data}) do
      resp(conn, {:ok, %{status: 0, content: data}})
    end

    defp resp_json(%Plug.Conn{}=conn, stat, data) when is_integer(stat) do
        {:ok, now} = DateTime.now("Etc/UTC")
        resp = %{
            status: stat,
            content: data,
            timestamp: now |> DateTime.to_string
        }

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(conn.status, Jason.encode_to_iodata!(resp))
        |> Plug.Conn.halt
    end
end
