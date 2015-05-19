#!/bin/bash

rails new trapp -d postgresql --skip-bundle
cd trapp

echo "gem 'devise'" >> Gemfile
bundle install

rails g devise:install
rails g devise User
rails g resource  profile   user:belongs_to name_first:string name_last:string github:string email:string phone:string

rails g model     record
rails g model     comment     record:belongs_to content:string

rails g model     course      record:belongs_to name:string
rails g resource  cohort      record:belongs_to
rails g model     day         record:belongs_to cohort:belongs_to

rails g resource  teacher     record:belongs_to user:belongs_to cohort:belongs_to
rails g resource  student     record:belongs_to user:belongs_to cohort:belongs_to
rails g resource  oneonone    record:belongs_to teacher:belongs_to student:belongs_to day:belongs_to 
rails g model     attendance  record:belongs_to student:belongs_to day:belongs_to

rails g model     subject     record:belongs_to name:string
rails g model     lesson      record:belongs_to subject:belongs_to
rails g model     assignment  record:belongs_to lesson:belongs_to day:belongs_to student:belongs_to

rake db:drop
rake db:create
rake db:migrate
