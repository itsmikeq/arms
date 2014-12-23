require 'rails/generators/active_record'
require_relative 'migration'

class Arms::ModelGenerator < Rails::Generators::NamedBase # :nodoc:
  include Rails::Generators::Migration
  include Arms::Migration
  attr_reader :datasource
  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"

  check_class_collision

  class_option :migration, :type => :boolean, default: true
  class_option :timestamps, :type => :boolean
  class_option :parent, :type => :string, :desc => "The parent class for the generated model"
  class_option :datasource, :type => :string, :desc => "The parent data source class for the generated model"
  class_option :indexes, :type => :boolean, :default => true, :desc => "Add indexes for references and belongs_to columns"
  source_root File.expand_path('../templates', __FILE__)

  # creates the migration file for the model.

  def create_migration_file
    return unless options[:migration] && options[:parent].nil?
    attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
    @datasource = options[:datasource]
    migration_template File.join(File.expand_path('../templates', __FILE__), 'migration.rb'), "db/migrate/create_#{table_name}.rb", {datasource: options[:datasource]}
  end

  def self.next_migration_number(dirname) #:nodoc:
    Time.now.to_i
  end

  def create_model_file
    template File.join(File.expand_path('../templates', __FILE__), 'model.rb'), File.join('app/models', class_path, "#{file_name}.rb")
  end

  def attributes_with_index
    attributes.select { |a| !a.reference? && a.has_index? }
  end

  def accessible_attributes
    attributes.reject(&:reference?)
  end

  hook_for :test_framework

  protected
  # Used by the migration template to determine the parent name of the model
  def parent_class_name
    options[:parent] || options[:datasource] || "ActiveRecord::Base"
  end

end
