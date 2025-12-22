defmodule Tunez.Music do
  use Ash.Domain,
    otp_app: :tunez,
    extensions: [AshPhoenix]

  resources do
    resource Tunez.Music.Artist do
      define :create_artist, action: :create
      define :get_artist_by_id, action: :read, get_by: :id
      define :list_artists, action: :read
      define :update_artist, action: :update
      define :destroy_artist, action: :destroy
    end
  end
end
