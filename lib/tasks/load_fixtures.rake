namespace :db do
  desc "Load fixtures from spec/fixtures"
  task load_fixtures: :environment do
    require 'active_record/fixtures'

    fixture_path = Rails.root.join('spec', 'fixtures')
    Dir[fixture_path.join('*.yml')].each do |fixture_file|
      ActiveRecord::FixtureSet.create_fixtures(fixture_path, File.basename(fixture_file, '.*'))
    end
  end
end
