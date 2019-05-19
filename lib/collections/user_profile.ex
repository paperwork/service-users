defmodule Paperwork.Collections.UserProfile do
    require Logger

    @collection "users"
    @privates []
    @enforce_keys []
    @type t :: %__MODULE__{
        id: BSON.ObjectId.t() | nil,
        email: String.t(),
        name: %{
            first_name: String.t(),
            last_name: String.t()
        }
    }
    defstruct \
        id: nil,
        email: "",
        name: %{
            first_name: "",
            last_name: ""
        }

    use Paperwork.Collections
end
