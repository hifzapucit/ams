defmodule Associations.Repo.Migrations.AlterCommentsTable do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :user_id, references(:users)
    end
  end
end
