defmodule Paperwork.Users.Endpoints.Login do
    require Logger
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
    end

    namespace :login do
        desc "Login User"
        params do
            requires :email, type: String
            requires :password, type: String
        end
        post do
            find_user = params

            with \
                {:ok, authenticated_user} <- struct(Paperwork.Collections.User, find_user) |> Paperwork.Collections.User.authenticate(),
                {:ok, jwt, _claims} <- Paperwork.Auth.Session.create(authenticated_user) do
                    conn
                    |> put_resp_header("Authorization", "Bearer #{jwt}")
                    |> resp({:ok, %{token: jwt, user: authenticated_user}})
            else
                other ->
                    Logger.debug("Authentication failed: #{inspect other}")
                    conn
                    |> resp({:badrequest, %{status: 1, content: %{error: "Authentication unsuccessful."}}})
            end

        end
    end
end
