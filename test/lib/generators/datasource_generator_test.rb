require 'test_helper'
require 'generators/datasource/datasource_generator'

class DatasourceGeneratorTest < Rails::Generators::TestCase
  tests DatasourceGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["arms:datasource name:string"]
    end
  end
end
