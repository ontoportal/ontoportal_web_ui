class CustomOntologies < ActiveRecord::Base
  serialize :ontologies, Array
end
