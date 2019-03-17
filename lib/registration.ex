defmodule Paperwork.Registration do
  use Paperwork.Server
  use Paperwork.Helpers.Response

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
      {:ok, created_user} = Paperwork.Collections.User.create(struct(Paperwork.Collections.User, params))
      {:ok, jwt, _full_claims} = Auth.Guardian.encode_and_sign(created_user, %{})

      conn
      |> put_resp_header("Authorization", "Bearer #{jwt}")
      |> response_json(%{ok: 0}, {:ok, %{token: jwt, user: created_user}})
    end
  end
end
