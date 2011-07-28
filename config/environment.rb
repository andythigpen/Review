# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Review::Application.initialize!

CHANGESET_STATUSES = {:accept => 1, :reject => 2, :abstain => 3}
