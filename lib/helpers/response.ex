defmodule Paperwork.Helpers.Response do
    defmacro __using__(_) do
        quote do
            import unquote(__MODULE__)
            import Plug.Conn
        end
    end

    def response_json(%Plug.Conn{}=conn, stat, data) when is_integer(stat) do
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

    def response_json(%Plug.Conn{}=conn, stat, data) when is_map(stat) do
        case data do
            {:ok, content}           -> conn |> Plug.Conn.put_status(200) |> response_json(stat.ok, content)
            {:badrequest, content}   -> conn |> Plug.Conn.put_status(400) |> response_json(stat.badrequest, content)
            {:unauthorized, content} -> conn |> Plug.Conn.put_status(401) |> response_json(stat.unauthorized, content)
            {:notfound, content}     -> conn |> Plug.Conn.put_status(404) |> response_json(stat.notfound, content)
            {:error, content}        -> conn |> Plug.Conn.put_status(500) |> response_json(stat.error, content)
            other                    -> conn |> Plug.Conn.put_status(500) |> response_json(500, other)
        end
    end
end
