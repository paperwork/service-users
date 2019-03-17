require Logger
require Jason

defmodule Paperwork.Collections do
  defmacro __using__(_opts) do
    quote do
      defimpl Jason.Encoder, for: [__MODULE__] do
        defp encode_id(%{:id => id} = value) when id != nil do
          value
          |> Map.put(:id, BSON.ObjectId.encode!(value.id))
        end

        defp encode_id(%{:id => id} = value) when id == nil do
          value
        end

        def encode(value, opts) do
          value
          |> encode_id
          |> Map.delete(:__struct__)
          |> Jason.Encode.map(opts)
        end
      end

      def keys_to_atoms(string_key_map) when is_map(string_key_map) do
        for {key, val} <- string_key_map, into: %{} do
          case Enumerable.impl_for val do
            nil -> {String.to_atom(key), val}
            _ -> {String.to_atom(key), keys_to_atoms(val)}
          end
        end
      end
      def keys_to_atoms(value), do: value

      @spec found_or_nil(result :: Map.t) :: {:ok, %__MODULE__{}}
      defp found_or_nil(%{"_id" => _id} = result) do
        {:ok, (struct(__MODULE__, keys_to_atoms(result)) |> Map.put(:id, result["_id"]))}
      end

      @spec found_or_nil(result :: {:ok, Map.t}) :: {:ok, %__MODULE__{}}
      defp found_or_nil({:ok, %{"_id" => _} = result}) do
        found_or_nil(result)
      end

      @spec found_or_nil(result :: %Mongo.Cursor{}) :: {:ok, [%__MODULE__{}]}
      defp found_or_nil([%{} | _] = results) when is_list(results) do
        {:ok, (results |> Enum.map(fn model ->
          {:ok, model_struct} = found_or_nil(model)
          model_struct
        end)) }
      end

      @spec found_or_nil(result :: nil) :: {:notfound, nil}
      defp found_or_nil(nil = result) do
        {:notfound, nil}
      end

      @spec ok_or_error(result :: {:ok, %{}} | {}, id_key :: Atom.t, model :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, String.t}
      def ok_or_error(result, id_key, model) do
        case result do
          {:ok, ok} ->
            {:ok, Map.put(model, :id, Map.get(ok, id_key))}
          other ->
            Logger.error "Error: #{inspect(other)}"
            {:error, "Internel Server Error"}
        end
      end

      @spec strip_privates({:ok, model :: %__MODULE__{}}) :: {:ok, %__MODULE__{}}
      def strip_privates({:ok, %__MODULE__{} = model}) do
        {:ok, Map.drop(model, @privates)}
      end

      @spec strip_privates({:ok, models :: [%__MODULE__{}]}) :: {:ok, [%__MODULE__{}]}
      def strip_privates({:ok, [%__MODULE__{} | _] = models}) when is_list(models) do
        {:ok, (models |> Enum.map(fn model -> Map.drop(model, @privates) end))}
      end

      @spec strip_privates({:notfound, nil}) :: {:notfound, nil}
      def strip_privates({:notfound, nil}) do
        {:notfound, nil}
      end

      defp real_key(key) do
        case key do
          :id -> :_id
          other -> other
        end
      end

      @spec collection_find(query :: Map.t, expect_many :: Boolean.t) :: {:ok, %__MODULE__{}} | {:ok, [%__MODULE__{}]} | {:notfound, nil}
      def collection_find(%{} = query, expect_many) when is_boolean(expect_many) and expect_many == true do
        Mongo.find(:mongo, @collection, query, pool: DBConnection.Poolboy)
        |> Enum.to_list
        |> found_or_nil
      end

      @spec collection_find(query :: Map.t, expect_many :: Boolean.t) :: {:ok, %__MODULE__{}} | {:ok, [%__MODULE__{}]} | {:notfound, nil}
      def collection_find(%{} = query, expect_many) when is_boolean(expect_many) and expect_many == false do
        Mongo.find_one(:mongo, @collection, query, pool: DBConnection.Poolboy)
        |> found_or_nil
      end

      @spec collection_find(query :: %__MODULE__{}, by_key :: Atom.t, expect_many :: Boolean.t) :: {:ok, %__MODULE__{}} | {:ok, [%__MODULE__{}]} | {:notfound, nil}
      def collection_find(%__MODULE__{} = model, by_key, expect_many \\ false) do
        collection_find(%{real_key(by_key) => Map.get(model, by_key)}, expect_many)
      end

      @spec collection_insert(query :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, String.t}
      def collection_insert(%__MODULE__{} = model) do
        Mongo.insert_one(:mongo, @collection, Map.delete(model, :id), pool: DBConnection.Poolboy)
        |> ok_or_error(:inserted_id, model)
      end

      @spec collection_update(query :: %__MODULE__{}, filter_key :: Atom.t) :: {:ok, %__MODULE__{}} | {:error, String.t}
      def collection_update(%__MODULE__{} = model, filter_key) do
        Mongo.find_one_and_update(:mongo, @collection, %{real_key(filter_key) => Map.get(model, filter_key)}, %{"$set": (Map.from_struct(model) |> Enum.filter(fn {k, v} -> v != nil && k != filter_key end) |> Enum.into(%{}))}, pool: DBConnection.Poolboy, return_document: :after)
        |> found_or_nil
      end

      @spec collection_update(query :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, String.t}
      def collection_update(%__MODULE__{} = model) do
        collection_update(model, :id)
      end

    end
  end
end

