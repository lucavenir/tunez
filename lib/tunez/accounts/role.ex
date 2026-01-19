defmodule Tunez.Accounts.Role do
  use Ash.Type.Enum,
    values: [
      admin: [description: "able to perform any action"],
      editor: [description: "able to create/update some resources"],
      user: [description: "can just read data"]
    ]
end
