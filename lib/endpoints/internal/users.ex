defmodule Paperwork.Users.Endpoints.Internal.Users do
    use Paperwork.Users.Server
    use Paperwork.Helpers.Response

    pipeline do
    end

    namespace :internal do
        namespace :users do
            get do
                response = Paperwork.Collections.User.list()

                conn
                |> resp(response)
            end

            route_param :id do
                get do
                    id = Paperwork.Id.from_gid(params[:id])
                    response = id |> Paperwork.Collections.User.show

                    conn
                    |> resp(response)
                end
            end
        end
    end
end
