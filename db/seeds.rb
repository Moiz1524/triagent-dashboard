# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
company = Company.find_or_create_by!(name: "Acme Security")
company.update!(github_repository: ENV.fetch("GITHUB_REPOSITORY", "Moiz1524/triagent-dashboard"))
admin = company.users.find_or_initialize_by(email: "admin@acme.test")
admin.update!(full_name: "Avery Admin", role: :super_admin, password: "Password123!", password_confirmation: "Password123!")
reviewer = company.users.find_or_initialize_by(email: "reviewer@acme.test")
reviewer.update!(full_name: "Riley Reviewer", role: :reviewer, password: "Password123!", password_confirmation: "Password123!")
sample = company.vulnerabilities.find_or_initialize_by(humanized_slug_id: "VULN-2026-DEMO01")
sample.update!(summary: "Unvalidated redirect target in account recovery", severity: :high, assessment_category: :exploitable, status: :in_review, possible_location: "app/controllers/password_resets_controller.rb:42", seen_at: 2.days.ago, initial_report: "A security researcher reported that the return_to parameter accepts an arbitrary external URL.", external_libs_details: [{ "name" => "rack", "repo_link" => "https://github.com/rack/rack" }])
sample.assigned_reviewers = [reviewer]
puts "Seeded Acme Security. Admin: admin@acme.test / Password123!"
