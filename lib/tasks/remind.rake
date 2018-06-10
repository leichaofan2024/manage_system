# encoding: utf-8
namespace :remind do
    desc "remind_retirement" 
	    task :retirement_remind => :environment do
	       Workshop.create(name: "workshop11")
	    end
    end
