source 'http://rubygems.org'

gem 'rails' #, '3.1.4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'warden' #, '1.1'
gem 'devise', '2.0.4'

gem 'kaminari'
gem "paperclip", '2.7.0'

# Use unicorn as the web server
gem 'unicorn'

gem 'mailman'
gem 'daemons'

gem 'delayed_job_active_record'
gem 'delayed_job_web'

# provides the auto_link functionality that was removed in rails 3.1
gem 'rails_autolink'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :production do
  gem 'mysql'
end

group :development do
  # gem 'letter_opener'
  gem 'mailcatcher'
  gem 'bullet'
  gem 'ruby-prof'
  gem 'active_record_query_trace'
end
