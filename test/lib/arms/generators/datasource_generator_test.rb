require_relative '../../../test_helper'

class Arms::DatasourceGeneratorTest < Rails::Generators::TestCase
  tests Arms::DatasourceGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination
  # puts ActiveRecord::Base.configurations[Rails.env]['test']
  puts ActiveRecord::Base.configurations[Rails.env]['test'] = {"test"=>{"adapter"=>"sqlite3", "pool"=>5, "timeout"=>5000, "database"=>"db/test_development.sqlite3"}}
  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["Test"]
    end

    assert File.exists?("test/dummy/tmp/generators/lib/test.rb")
  end
end
