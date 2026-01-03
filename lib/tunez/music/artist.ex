defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  actions do
    defaults [:create, :read, :destroy]
    default_accept [:name, :biography]

    update :update do
      accept [:name, :biography]
      require_atomic? false
      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    read :search do
      pagination offset?: true, default_limit: 12

      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string, allow_nil?: false, public?: true
    attribute :biography, :string
    attribute :previous_names, {:array, :string}, default: []

    timestamps(public?: true)
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      sort year_released: :desc
    end
  end

  calculations do
    calculate :album_count, :integer, expr(count(albums))
    calculate :latest_album_year_released, :integer, expr(first(albums, field: :year_released))
    calculate :cover_image_url, :string, expr(first(albums, field: :cover_image_url))
  end
end
