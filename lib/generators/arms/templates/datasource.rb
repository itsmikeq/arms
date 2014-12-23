class <%= name.camelize %> < ActiveRecord::Base
  self.establish_connection(ActiveRecord::Base.configurations[Rails.env]['<%=name%>'])

end