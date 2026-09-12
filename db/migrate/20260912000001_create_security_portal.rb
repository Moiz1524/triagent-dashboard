class CreateSecurityPortal < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :github_repository
      t.timestamps
    end

    create_table :users do |t|
      t.references :company, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.integer :role, null: false, default: 1
      t.timestamps
    end
    add_index :users, [:company_id, :email], unique: true

    create_table :vulnerabilities do |t|
      t.references :company, null: false, foreign_key: true
      t.string :humanized_slug_id, null: false
      t.integer :assessment_category
      t.string :possible_location
      t.text :summary
      t.integer :severity
      t.string :remediation_link
      t.datetime :seen_at
      t.jsonb :external_libs_details, null: false, default: []
      t.integer :status, null: false, default: 0
      t.text :initial_report
      t.string :github_issue_url
      t.boolean :archived, null: false, default: false
      t.timestamps
    end
    add_index :vulnerabilities, [:company_id, :humanized_slug_id], unique: true
    add_index :vulnerabilities, :github_issue_url, unique: true
    add_index :vulnerabilities, [:company_id, :archived, :status]

    create_table :assignments do |t|
      t.references :vulnerability, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :assignments, [:vulnerability_id, :user_id], unique: true
  end
end
