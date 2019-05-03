defmodule Paperwork.Users.Endpoints.Users do
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
        plug Paperwork.Auth.Plug.SessionLoader
    end

    namespace :users do
        get do
            response = case conn |> Paperwork.Auth.Session.get_user_role do
                :role_admin ->
                    Paperwork.Collections.User.list()
                _ ->
                    {:unauthorized, %{status: 0, content: %{error: "Not authorized to list all users"}}}
            end

            conn
            |> resp(response)
        end

        route_param :id do
            get do
                session_user_id = conn |> Paperwork.Auth.Session.get_user_id
                session_user_role = conn |> Paperwork.Auth.Session.get_user_role
                show_user = params

                response = cond do
                    session_user_id != show_user[:id] and session_user_role != :role_admin -> {:unauthorized, %{status: 0, content: %{error: "Not authorized to view other users"}}}
                    true -> BSON.ObjectId.decode!(params[:id]) |> Paperwork.Collections.User.show
                end

                conn
                |> resp(response)
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
            put do
                session_user_id = conn |> Paperwork.Auth.Session.get_user_id
                session_user_role = conn |> Paperwork.Auth.Session.get_user_role
                update_user = params

                response = cond do
                    session_user_id != update_user[:id] and session_user_role != :role_admin -> {:unauthorized, %{status: 0, content: %{error: "Not authorized to update other users"}}}
                    true -> struct(Paperwork.Collections.User, update_user)
                            |> Map.put(:id, params[:id])
                            |> Map.put(:updated_at, DateTime.utc_now())
                            |> Paperwork.Collections.User.update
                end

                conn
                |> resp(response)
            end
        end
    end
end