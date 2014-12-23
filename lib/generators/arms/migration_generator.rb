require 'rails/generators/active_record'
require_relative 'migration'
# require 'rails/generators/rails/migration/migration_generator'

class Arms::MigrationGenerator < Rails::Generators::NamedBase # :nodoc:
  include Rails::Generators::Migration
  include ::Arms::Migration
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"
  class_option :datasource, type: :string, :default => "ActiveRecord::Base", desc: "Set a data source, defaults to ActiveRecord::Base,
                                             # alternate data source must have been created with
                                             # rails g datasource <data source>"

  def create_migration_file
    puts "options: #{options.inspect}"
    set_local_assigns!
    validate_file_name!
    migration_template @migration_template, "db/migrate/#{file_name}.rb"
  end

  protected
  private
  def attributes_with_index
    attributes.select { |a| !a.reference? && a.has_index? }
  end

  def validate_file_name!
    unless file_name =~ /^[_a-z0-9]+$/
      raise IllegalMigrationNameError.new(file_name)
    end
  end

  def normalize_table_name(_table_name)
    pluralize_table_names? ? _table_name.pluralize : _table_name.singularize
  end


end
