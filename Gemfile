source 'https://gems.ruby-china.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.5'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'



# 登录
gem 'devise'
# 角色库
gem 'rolify'
# 用户权限
gem 'cancancan'

# 通知系统
gem "notifications"
gem "ruby-push-notifications"

#上传头像
gem 'carrierwave'
gem 'mini_magick'

gem 'bootstrap-sass'
gem 'awesome_rails_console'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'simple_form'
#上传下载表格
gem 'roo'
gem 'roo-xls'

gem 'kaminari'
#controller与js的参数传递
gem 'gon'

gem 'font-awesome-rails'
gem 'ransack'


#异步
gem 'sidekiq'

#时间选择器
gem 'bootstrap-datepicker-rails'

# 中文翻译
gem 'rails-i18n'
gem 'devise-i18n'

gem "select2-rails"

gem "nested_form_fields"

group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'pry'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rails-erd'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
