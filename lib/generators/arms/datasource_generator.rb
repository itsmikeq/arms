require 'rails/generators'

class Arms::DatasourceGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Actions
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string, :default => Rails.env, :banner => "Named data source, must exist in #{Rails.env} section of database.yml, defaults to #{Rails.env}"

  def create_datasource_file
    set_local_assigns!
    unless check_exists?
      raise ArgumentError.new "Unable to find #{name} in database.yml"
    end
    datasource_template @datasource_template, "lib/#{name}.rb"
  end

  protected
  attr_accessor :file_path, :name, :datasource_template, :destination

  def set_local_assigns!
    @name = name.downcase.singularize
    @datasource_template = "datasource.rb"
  end

  def file_exists?
    if File.exists?(destination)
      puts "File #{destination} already exists, please remove it first to recreate"
      raise ArgumentError.new "Already exists"
    end
  end

  def check_exists?
    ActiveRecord::Base.configurations[Rails.env][@name]
  end

  def create_datasource(destination, data, config = {}, &block)
    lib(File.basename(destination), block || data.to_s)
  end

  def set_datasource_assigns!(destination)
    @destination = File.expand_path(destination, self.destination_root)
    file_exists?
    # puts "Destination: #{destination}"
    @datasource_file_name  = File.basename(destination, '.rb')
    @datasource_class_name = @datasource_file_name.camelize
  end

  def datasource_template(source, destination, config = {})
    # puts "Source: #{source}"
    # puts "Source: #{find_in_source_paths(source.to_s)}"
    source  = File.expand_path(find_in_source_paths(source.to_s))
    # puts "Destination: #{destination}"
    set_datasource_assigns!(destination)
    context = instance_eval('binding')
    # puts "Source: #{ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)}"

    _data = ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)
    create_datasource destination, _data, config
  end

end
