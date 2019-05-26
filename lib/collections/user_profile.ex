defmodule Paperwork.Collections.UserProfile do
    require Logger

    @collection "users"
    @privates []
    @enforce_keys []
    @type t :: %__MODULE__{
        id: BSON.ObjectId.t() | nil,
        gid: String.t(),
        email: String.t(),
        name: %{
            first_name: String.t(),
            last_name: String.t()
        },
        profile_photo: String.t() | nil
    }
    defstruct \
        id: nil,
        gid: "",
        email: "",
        name: %{
            first_name: "",
            last_name: ""
        },
        profile_photo: nil

    use Paperwork.Collections
end
