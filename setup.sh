#!/bin/bash

rm -rf trapp
rails new trapp -d postgresql --skip-bundle
cd trapp

cat <<EOT > config/application.rb
require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(*Rails.groups)
module Trapp
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.generators.stylesheets = false
    config.generators.javascripts = false
  end
end
EOT

echo "gem 'devise'" >> Gemfile
bundle install

rake db:drop
rake db:create

rails g devise:install
rails g devise User
rails g devise:views
rails g devise:controllers users

mkdir -p app/views/users/sessions
cp -pR app/views/devise/sessions/ app/views/users/sessions/
rm -rf app/views/devise/sessions

rails g migration AddFieldsToUsers first_name:string last_name:string github:string phone:string

rails g scaffold  record
rails g scaffold  comment     record:belongs_to content:string

rails g scaffold  course      record:belongs_to name:string
rails g scaffold  cohort      record:belongs_to

rails g scaffold  teacher     record:belongs_to user:belongs_to cohort:belongs_to
rails g scaffold  student     record:belongs_to user:belongs_to cohort:belongs_to
rails g scaffold  oneonone    record:belongs_to teacher:belongs_to student:belongs_to 
rails g scaffold  attendance  record:belongs_to student:belongs_to stat:integer

rails g scaffold  lesson      record:belongs_to name:string
rails g scaffold  assignment  record:belongs_to lesson:belongs_to link:string
rails g scaffold  submission  record:belongs_to assignment:belongs_to student:belongs_to stat:integer link:string

rake db:migrate

mkdir app/views/application
touch app/views/application/index.html.erb
echo '<p class="notice"><%= notice %></p>' >> app/views/application/index.html.erb
echo '<p class="alert"><%= alert %></p>' >> app/views/application/index.html.erb

cat <<EOT > config/routes.rb
Rails.application.routes.draw do
  resources :records
  resources :comments
  resources :courses
  resources :cohorts
  resources :teachers
  resources :students
  resources :oneonones
  resources :attendances
  resources :lessons
  resources :assignments
  resources :submissions
  devise_for :users, controllers: { sessions: "users/sessions" }
  root "application#index"
end
EOT

cat <<EOT >> app/assets/stylesheets/application.html.erb
*
{
	margin:0;
	border:0;
	padding:0;
	border-collapse:collapse;
	border-spacing:0;
	font-weight:inherit;
	font-size:inherit;
	font-style:inherit;
	color:inherit;
	background-color:transparent;
	box-sizing:border-box;
	font-family:inherit
}
input[type=text],
textarea
{
  background-color:#eee;
}
input[type=text]:focus,
textarea:focus
{
	outline:0;
  background-color:#ddd;
}
EOT

cat <<EOT > app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  def index
  end
end
EOT

