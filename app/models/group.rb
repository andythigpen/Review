class Group < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :group_members
  has_many :members, :through => :group_members, :source => :user
  accepts_nested_attributes_for :group_members, :allow_destroy => true,
        :reject_if => proc { |attributes| !attributes['_destroy'] and attributes['user_id'].blank? }

  validates_presence_of :name
end
