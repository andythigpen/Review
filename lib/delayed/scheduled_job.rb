#
# Modified From https://gist.github.com/1024726
# Recurring Job using Delayed::Job
# 
# Setup Your job the "plain-old" DJ (perform) way, include this module 
# and Your handler will re-schedule itself every time it succeeds. 
# 
# Sample :
#
#     class MyJob
#       include Delayed::ScheduledJob
#
#       run_every 1.day
#
#       def display_name
#         "MyJob"
#       end
#
#       def perform
#         # code to run ...
#       end
#
#    end
#
# inspired by http://rifkifauzi.wordpress.com/2010/07/29/8/
#
module Delayed
  module ScheduledJob
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        @@logger = Delayed::Worker.logger
        cattr_reader :logger
      end
    end

    def perform_with_schedule
      perform_without_schedule
      schedule! # only schedule if job did not raise
    end

    # schedule this "repeating" job
    def schedule!(run_at = nil)
      run_at ||= self.class.run_at
      Delayed::Job.enqueue self, :priority => 0, :run_at => run_at.utc
    end

    # re-schedule this job instance
    def reschedule!
      schedule! Time.now
    end

    module ClassMethods

      def method_added(name)
        if name.to_sym == :perform &&
            ! instance_methods(false).map(&:to_sym).include?(:perform_without_schedule)
          alias_method_chain :perform, :schedule
        end
      end

      def run_at
        run_interval.from_now.localtime.change(@time_at)
      end

      def run_interval
        @time_at ||= {}
        @run_interval ||= 1.hour
      end

      # run_every 1.day, :at => {:hour => 0, :min => 1, :sec => 2}
      def run_every(time, opts={})
        opts[:at] ||= {}
        @time_at = opts[:at]
        @run_interval = time
      end

      def schedule(run_at = nil)
        schedule!(run_at) unless scheduled?
      end
      
      def schedule!(run_at = nil)
        new.schedule!(run_at)
      end

      def scheduled?
        Delayed::Job.where("handler LIKE ?", "%#{name}%").count > 0
      end

    end

  end
end
