defmodule Paperwork.Users do
  use Paperwork.Server
  use Paperwork.Helpers.Response

  pipeline do
    plug Auth.Plug.AccessPipeline
  end

  namespace :users do
    get do
      {:ok, users} = Paperwork.Collections.User.list()
      conn
      |> response_json(%{ok: 0}, {:ok, users})
    end

    route_param :id do
      get do
        {:ok, user} = Paperwork.Collections.User.show(BSON.ObjectId.decode!(params[:id]))
        conn
        |> response_json(%{ok: 0}, {:ok, user})
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
        {:ok, user} = (struct(Paperwork.Collections.User, params) |> Map.put(:id, BSON.ObjectId.decode!(params[:id])) |> Paperwork.Collections.User.update)
        conn
        |> response_json(%{ok: 0}, {:ok, user})
      end
    end
  end
end
