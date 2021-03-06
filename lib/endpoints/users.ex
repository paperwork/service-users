defmodule Paperwork.Users.Endpoints.Users do
    require Logger
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
        plug Paperwork.Auth.Plug.SessionLoader
    end

    namespace :users do
        get do
            session_user_id =
                conn
                |> Paperwork.Auth.Session.get_paperwork_id()

            session_user_role =
                conn
                |> Paperwork.Auth.Session.get_user_role()

            response = case session_user_role do
                :role_admin ->
                    Paperwork.Collections.User.list()
                _ ->
                    {:ok, users} = Paperwork.Collections.User.list()
                    {:ok,
                        users
                        |> Enum.map(fn user ->
                            extended_user =
                                user
                                |> Map.put(:gid, "#{Map.get(user, :id) |> BSON.ObjectId.encode!()}@#{session_user_id.system_id}")

                            struct(Paperwork.Collections.UserProfile, Map.take(extended_user, Paperwork.Collections.UserProfile.fields()))
                        end)
                    }
            end

            conn
            |> resp(response)
        end

        route_param :id do
            get do
                session_user_id =
                    conn
                    |> Paperwork.Auth.Session.get_paperwork_id()

                session_user_role =
                    conn
                    |> Paperwork.Auth.Session.get_user_role()

                show_user_id =
                    params[:id]
                    |> Paperwork.Id.from_gid()

                response = cond do
                    session_user_id != show_user_id and session_user_role != :role_admin ->
                        {:ok, user} = show_user_id |> Paperwork.Collections.User.show

                        extended_user =
                            user
                            |> Map.put(:gid, "#{Map.get(user, :id) |> BSON.ObjectId.encode!()}@#{session_user_id.system_id}")

                        {:ok, struct(Paperwork.Collections.UserProfile, Map.take(extended_user, Paperwork.Collections.UserProfile.fields()))}
                    true ->
                        show_user_id |> Paperwork.Collections.User.show
                end

                conn
                |> resp(response)
            end

            desc "Update User"
            params do
                optional :email, type: String
                optional :password, type: String
                optional :name, type: Map do
                    optional :first_name, type: String
                    optional :last_name, type: String
                end
                optional :profile_photo, type: String
            end
            put do
                session_user_id =
                    conn
                    |> Paperwork.Auth.Session.get_paperwork_id()

                session_user_role =
                    conn
                    |> Paperwork.Auth.Session.get_user_role()

                update_user_id =
                    params[:id]
                    |> Paperwork.Id.from_gid()
                    |> IO.inspect

                response = cond do
                    session_user_id != update_user_id and session_user_role != :role_admin ->
                        {:unauthorized, %{status: 0, content: %{error: "Not authorized to update other users"}}}
                    true ->
                        params
                            |> Map.put(:id, update_user_id.id)
                            |> Map.put(:updated_at, DateTime.utc_now())
                            |> Paperwork.Collections.User.update
                            |> Paperwork.Helpers.Journal.api_response_to_journal(
                                case params |> Map.has_key?(:password) do
                                    true -> params |> Map.put(:password, "CENSORED")
                                    false -> params
                                end, :update, :user, :user, session_user_id.gid, [session_user_id])
                end

                conn
                |> resp(response)
            end

            namespace :journals do
                params do
                    optional :resource,           type: String
                    optional :newer_than_id,      type: String
                end
                get do
                    session_user_id =
                        conn
                        |> Paperwork.Auth.Session.get_paperwork_id()

                    session_user_role =
                        conn
                        |> Paperwork.Auth.Session.get_user_role()

                    show_user_id =
                        params[:id]
                        |> Paperwork.Id.from_gid()

                    response = cond do
                        session_user_id != show_user_id and session_user_role != :role_admin ->
                            {:unauthorized, "Not authorized to see other user's journals!"}
                        true ->
                            journals_params =
                                %{
                                    relevant_to: show_user_id.gid,
                                    resource: params |> Map.get(:resource),
                                    newer_than_id: params |> Map.get(:newer_than_id)
                                }

                            with \
                                {:ok, _} <- Paperwork.Id.validate_gid(show_user_id.gid),
                                {:ok, journals} <- Paperwork.Internal.Request.journals(journals_params)
                            do
                                {:ok, journals}
                            else
                                {:notfound, _} ->
                                    Logger.warn("Internal request returned 404")
                                    {:notfound, ""}
                                other ->
                                    Logger.error("Validation of access GID failed: #{inspect other}")
                                    {:badrequest, "Supplied GID (#{inspect show_user_id}) seems to be invalid"}
                            end
                    end

                    conn
                    |> resp(response)
                end
            end

        end
    end
end
