defmodule Paperwork.Users do
    use Paperwork.Server
    use Paperwork.Helpers.Response

    pipeline do
        plug Paperwork.Auth.Plug.SessionLoader
    end

    namespace :users do
        get do
            {:ok, users} = Paperwork.Collections.User.list()
            conn
            |> resp({:ok, users})
        end

        route_param :id do
            get do
                {:ok, user} = BSON.ObjectId.decode!(params[:id]) |> Paperwork.Collections.User.show
                conn
                |> resp({:ok, user})
            end

            desc "Update User"
            params do
                optional :email, type: String
                optional :password, type: String
                group :name, type: Map do
                    optional :first_name, type: String
                    optional :last_name, type: String
                end
            end
            post do
                session_user = conn |> Paperwork.Auth.Session.get
                IO.inspect session_user
                update_user = params
                |> Map.put(:id, params[:id])
                |> Map.put(:updated_at, DateTime.utc_now())

                response = cond do
                    session_user[:id] != update_user[:id] and session_user[:role] != :role_admin -> {:unauthorized, %{status: 0, content: %{error: "Not authorized to update other users"}}}
                    true -> struct(Paperwork.Collections.User, update_user) |> Paperwork.Collections.User.update
                end

                conn
                |> resp(response)
            end
        end
    end
end
