class EffortLogLineItem < ActiveRecord::Base
    belongs_to :effort_log
    belongs_to :task_type
    belongs_to :project
    belongs_to :course
  
#    before_save :determine_total_effort #this is not necessary since it is also called by the effort_log before a save
      
    
    def determine_total_effort
      self.sum = 0
      self.sum = self.sum + self.day1 if !self.day1.nil?
      self.sum = self.sum + self.day2 if !self.day2.nil?
      self.sum = self.sum + self.day3 if !self.day3.nil?
      self.sum = self.sum + self.day4 if !self.day4.nil?
      self.sum = self.sum + self.day5 if !self.day5.nil?
      self.sum = self.sum + self.day6 if !self.day6.nil?
      self.sum = self.sum + self.day7 if !self.day7.nil?
    end
end
