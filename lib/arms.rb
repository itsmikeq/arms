require_relative 'generators/arms/datasource_generator'
require_relative 'generators/arms/migration'
require_relative 'generators/arms/model_generator'
require 'active_support/all'
require 'active_record'
module Arms
  class DataSourceNotFoundError < StandardError ; end
  autoload :Arms, 'Arms'
  Dir.glob("../../generators/arms/*.rb").each do |f|
    puts "Requiring #{f}"
    require f
  end
end
