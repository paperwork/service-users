defmodule Paperwork.Users.Endpoints.Internal.Users do
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
    end

    namespace :internal do
        namespace :users do
            get do
                {:ok, users} = Paperwork.Collections.User.list()
                conn
                |> resp({:ok, users})
            end

            route_param :id do
                get do
                    id = Paperwork.Id.from_gid(params[:id])
                    {:ok, user} = id |> Paperwork.Collections.User.show
                    conn
                    |> resp({:ok, user})
                end
            end
        end
    end
end
