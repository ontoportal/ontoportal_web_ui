class CreateNewsEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :news_entries do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.text :body_html, null: false
      t.string :status, null: false, default: 'draft'
      t.datetime :published_at
      t.datetime :expires_at
      t.boolean :pinned, null: false, default: false
      t.string :author_id
      t.string :author_name
      t.timestamps
    end

    add_index :news_entries, :slug, unique: true
    add_index :news_entries, [:status, :published_at, :expires_at]
    add_index :news_entries, [:pinned, :published_at]
  end
end
