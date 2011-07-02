class User < ActiveRecord::Base
  has_many :reviews_owned, :class_name => "ReviewEvent", :dependent => :destroy
  has_many :review_event_users
  has_many :review_requests, :through => :review_event_users, 
           :source => :review_event, :order => "updated_at DESC"
  has_many :comments, :dependent => :destroy
  has_many :changeset_user_statuses, :dependent => :destroy
  has_one :profile

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username,
                  :first_name, :last_name

  def current_requests
    res = []
    self.review_requests.each do |r|
      latest = r.changesets.last
      # filter out those without changesets or submitted changesets
      next if latest.nil? or not latest.submitted

      next if latest.statuses.nil? 
      status = latest.statuses.find_by_user_id(self.id)
      if not status.nil?
        # filter out accepted requests older than 1 day
        next if status.accepted and (status.updated_at.to_date + 1).past?
        # filter out rejected requests older than 7 days
        next if not status.accepted and (status.updated_at.to_date + 7).past?
      end

      yield r if block_given?
      res.push(r)
    end
    res
  end
end
