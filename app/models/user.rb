class User < ApplicationRecord
  validates :email, :uniqueness => true, :on => :create
end
