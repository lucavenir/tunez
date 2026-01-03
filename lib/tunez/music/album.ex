defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "albums"
    repo Tunez.Repo

    references do
      reference :artist, index?: true, on_delete: :delete
    end
  end

  actions do
    defaults [:create, :read, :destroy]
    default_accept [:name, :year_released, :cover_image_url, :artist_id]

    update :update do
      accept [:name, :year_released, :cover_image_url]
    end
  end

  validations do
    validate numericality(
               :year_released,
               greater_than_or_equal_to: 1889,
               less_than_or_equal_to: &__MODULE__.next_year/0
             ),
             where: [present(:year_released)],
             message: "must be between 1889 and the next year"

    validate match(
               :cover_image_url,
               ~r"^(https://|/images/).+(\.png|\.jpg)$"
             ),
             where: [changing(:cover_image_url)],
             message: "must start with https:// or /images/, and must end with .png or .jpg"
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :year_released, :integer, allow_nil?: false
    attribute :cover_image_url, :string

    timestamps()
  end

  relationships do
    belongs_to :artist, Tunez.Music.Artist, allow_nil?: false
  end

  calculations do
    # the following obviously sucks, it's just a quick experiment, but more on that later
    calculate :years_ago, :integer, expr(2025 - year_released)

    calculate :years_ago_wow,
              :string,
              expr("wow, this was released " <> years_ago <> " years ago!")
  end

  def next_year, do: Date.utc_today().year + 2

  identities do
    identity :unique_album_per_artist, [:name, :artist_id],
      message: "an album with this name already exists for this artist"
  end
end
