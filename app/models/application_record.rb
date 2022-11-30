class ApplicationRecord < ActiveRecord::Base
  include PgSearch::Model
  primary_abstract_class
end
