source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'spree', :git => 'git://github.com/spree/spree.git', :branch => '0-70-stable'
gem 'spree_rdr_theme', :git => 'git://github.com/spree/spree_rdr_theme.git'

gem 'pg'
gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :test, :development do
  gem 'capistrano'
end

group :production do
  gem 'mysql2', '0.3.7'
  gem 'foreman'
  gem 'unicorn'
  gem 'therubyracer'
end
