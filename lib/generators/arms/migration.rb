require 'rails/generators/migration'

module Arms::Migration
  include ActiveSupport::Concern
  include Rails::Generators::Migration
  extend Rails::Generators::Migration

  attr_reader :migration_action, :join_tables
  attr_reader :datasource
  mattr_reader :stock_migration_ran

  # sets the default migration template that is being used for the generation of the migration
  # depending on the arguments which would be sent out in the command line, the migration template
  # and the table name instance variables are setup.


  def self.next_migration_number(dirname) #:nodoc:
    Time.now.to_i
  end

  def check_for_parent!
    return true if @stock_migration_ran
    _ds_file = Rails.root.join("lib/#{options[:datasource].downcase}.rb")
    unless (File.exists?(_ds_file) rescue true)
      raise Arms::DataSourceNotFoundError.new "Unable to find datasource #{_ds_file}"
    end
  end

  def set_local_assigns!
    @datasource = options[:datasource]
    puts "Datasource: #{@datasource}"

    if @datasource == "ActiveRecord::Base"
      puts "running default generator"
      @stock_migration_ran = true
    end

    check_for_parent!
    # puts "Set datasource to #{@datasource}"
    # puts "Attributes: #{attributes}"

    @migration_template = "migration.rb"
    case file_name
    when /^(add|remove)_.*_(?:to|from)_(.*)/
      @migration_action = $1
      @table_name = normalize_table_name($2)
    when /join_table/
      if attributes.length == 2
        @migration_action = 'join'
        @join_tables = pluralize_table_names? ? attributes.map(&:plural_name) : attributes.map(&:singular_name)

        set_index_names
      end
    when /^create_(.+)/
      @table_name = normalize_table_name($1)
      @migration_template = "create_table_migration.rb"
    end
  end

  def set_index_names
    attributes.each_with_index do |attr, i|
      attr.index_name = [attr, attributes[i - 1]].map { |a| index_name_for(a) }
    end
  end

  def index_name_for(attribute)
    if attribute.foreign_key?
      attribute.name
    else
      attribute.name.singularize.foreign_key
    end.to_sym
  end


  def migration_template(source, destination, config = {})
    source  = File.expand_path(find_in_source_paths(source.to_s))

    set_migration_assigns!(destination)
    context = instance_eval('binding')

    dir, base = File.split(destination)
    numbered_destination = File.join(dir, ["%migration_number%", base].join('_'))

    create_migration numbered_destination, nil, config do
      ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)
    end
  end

end