source 'http://rubygems.org'

gem 'rails', "~> 4.2.0"

gem 'apipie-rails'
gem 'aasm'
gem 'actionpack-action_caching'
gem 'actionpack-page_caching'
gem 'acts-as-taggable-on', '~> 3.4'
gem 'addressable', :require => 'addressable/uri'
gem 'airbrake'
gem 'ancestry'
gem 'aws-sdk'
gem 'bluecloth'
gem 'capistrano'
gem 'capistrano-passenger'
gem 'chronic'
gem 'cocoon' # JY: Added to support nested attributes for assessment_sections on assessments
gem 'daemons'
gem 'daemon-spawn'
gem 'dbf'
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'devise'
gem 'devise-encryptable'
gem 'devise_suspendable'
gem 'diffy'
gem 'doorkeeper'
gem 'dynamic_form'
gem 'exifr'
gem 'flickraw', "~> 0.9.8", :git => 'git://github.com/kueda/flickraw.git', :branch => 'ssl-cert'
gem "friendly_id", "~> 5.0.1"
gem 'gdata', :git => 'git://github.com/dwaite/gdata.git'
gem 'geocoder'
gem 'geoplanet'
gem 'google-api-client'
gem 'georuby', :git => 'git://github.com/kueda/georuby.git'
gem 'haml'
gem 'htmlentities'
gem 'i18n-js', :git => 'git://github.com/fnando/i18n-js.git'
# gem 'irwi', :git => 'git://github.com/alno/irwi.git'
gem 'json'
gem 'jquery-rails'
gem 'koala'
gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'
gem 'dalli'
gem 'mocha', :require => false
gem 'mobile-fu', :git => 'https://github.com/kueda/mobile-fu.git'
gem 'nokogiri'
gem 'omniauth-facebook'
gem 'omniauth-flickr'
gem 'omniauth-openid'
gem "omniauth-google-oauth2"
gem 'omniauth-soundcloud'
gem 'omniauth-twitter'
gem 'objectify-xml', :require => 'objectify_xml'
gem "paperclip", "3.4.2"
gem 'delayed_paperclip', :git => 'git://github.com/jrgifford/delayed_paperclip.git'
gem 'pg'
gem 'preferences', :git => 'git://github.com/kueda/preferences.git'
gem 'rack-google-analytics', :git => 'git://github.com/kueda/rack-google-analytics.git', :branch => 'eval-blocks-per-request'
gem 'rails-observers'
gem 'rakismet'
gem 'rest-client', :require => 'rest_client'
gem 'right_aws', :git => 'git://github.com/rightscale/right_aws.git'
gem 'right_http_connection'
gem 'rinku', :require => 'rails_rinku'
gem 'riparian', :git => 'git://github.com/kueda/riparian.git'
gem 'rvm-capistrano'
gem 'savon'   #allow to consume soap services with WSDL
gem 'sass', '= 3.2.5'
gem 'sass-rails'
gem 'soundcloud'
gem 'mysql2', '~> 0.3.17'
gem 'thinking-sphinx', '~> 3.1'
gem 'translate-rails3', :require => 'translate', :git => 'git://github.com/JayTeeSF/translate.git'
gem 'trollop'
gem 'ts-delayed-delta', '~> 2.0.2'
gem 'twitter'
gem 'uglifier'
gem 'utf8-cleaner'
gem "watu_table_builder", :require => "table_builder"
gem 'wicked_pdf'
gem 'will_paginate'
gem 'whenever', :require => false
gem 'ya2yaml'
gem 'yui-compressor'
# This used to pull from git://github.com/eknoop/xmp.git and might require
# pulling into https://github.com/eknoop/xmp/commit/b07bd072239a84c7b8c2967c33
# 21066477e03a88 into a fork of our own...
gem 'xmp', :git => 'git://github.com/jkraemer/xmp.git'
gem 'statsd-ruby', :require => 'statsd'

gem 'rgeo'
gem 'activerecord-postgis-adapter', :git => 'git://github.com/kueda/activerecord-postgis-adapter.git', :branch => 'activerecord42'

group :production do
  gem 'newrelic_rpm'
end

group :test, :development, :prod_dev do
  gem "database_cleaner"
  gem "machinist"
  gem "rspec-rails"
  gem "rspec-html-matchers"
  gem "better_errors"
  gem "byebug"
  gem "binding_of_caller"
  gem 'thin', '~> 1.6.3'
end

group :test do
  gem 'faker'
  gem 'simplecov', :require => false
end

group :assets do
  gem 'turbo-sprockets-rails3'
end
