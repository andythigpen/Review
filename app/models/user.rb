class User < ActiveRecord::Base
  has_many :reviews_owned, :class_name => "ReviewEvent"
  has_many :review_event_users
  has_many :review_requests, :through => :review_event_users, :source => :review_event
  has_many :comments

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username
end
