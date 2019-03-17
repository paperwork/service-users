defmodule Paperwork.Registration do
  use Paperwork.Server
  use Paperwork.Helpers.Response

  pipeline do
    plug Auth.Plug.AccessPipeline.Unauthenticated
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
    end
    post do
      new_user = params
      |> Map.put("role", :role_user)

      {:ok, created_user} = struct(Paperwork.Collections.User, new_user)
        |> Paperwork.Collections.User.create()
      {:ok, jwt, _full_claims} = Auth.Guardian.encode_and_sign(created_user, %{})

      conn
      |> put_resp_header("Authorization", "Bearer #{jwt}")
      |> resp({:ok, %{token: jwt, user: created_user}})
    end
  end
end
