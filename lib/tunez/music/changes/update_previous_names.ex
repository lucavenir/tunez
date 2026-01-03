defmodule Tunez.Music.Changes.UpdatePreviousNames do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    new_name = Ash.Changeset.get_attribute(changeset, :name)
    old_name = Ash.Changeset.get_data(changeset, :name)
    previous_names = Ash.Changeset.get_data(changeset, :previous_names)

    names =
      [old_name | previous_names]
      |> Enum.uniq()
      |> Enum.reject(fn name -> name == new_name end)

    Ash.Changeset.change_attribute(changeset, :previous_names, names)
  end
end
