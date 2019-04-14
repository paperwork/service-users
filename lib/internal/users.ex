defmodule Paperwork.Internal.Users do
    use Paperwork.Server
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
                    {:ok, user} = BSON.ObjectId.decode!(params[:id]) |> Paperwork.Collections.User.show
                    conn
                    |> resp({:ok, user})
                end
            end
        end
    end
end
