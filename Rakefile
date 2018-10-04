# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

namespace :db do

  desc "db:migration fakes"
  task :migrate => :environment do
    p '**NOte** Kris change this when using a postgres DB..No. We will not migrate!'
  end

end

Rails.application.load_tasks
