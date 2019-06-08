defmodule Paperwork.Users.Endpoints.Registration do
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
    end

    namespace :registration do
        desc "Register User"
        params do
            requires :email, type: String
            requires :password, type: String
            group :name, type: Map do
                requires :first_name, type: String
                requires :last_name, type: String
            end
            optional :profile_photo, type: String
        end
        post do
            new_user = params
            |> Map.put("role", :role_user)

            with \
                {:ok, created_user} <- struct(Paperwork.Collections.User, new_user) |> Paperwork.Collections.User.create(),
                {:ok, jwt, _claims} <- Paperwork.Auth.Session.create(created_user) do

                    new_user_id =
                        Paperwork.Id.from_gid(created_user.id |> BSON.ObjectId.encode!())

                    {:ok, created_user}
                    |> Paperwork.Helpers.Journal.api_response_to_journal(params |> Map.put(:password, "CENSORED"), :create, :user, :user, new_user_id.gid, [new_user_id])

                    conn
                    |> put_resp_header("Authorization", "Bearer #{jwt}")
                    |> resp({:ok, %{token: jwt, user: created_user}})
            else
                _ ->
                    conn
                    |> resp({:error, %{status: 1, content: %{error: "Something bad happened. Please try again."}}})
            end

        end
    end
end
