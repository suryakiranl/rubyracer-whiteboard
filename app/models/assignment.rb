# Assignment is the task/deliverable on which the professor grades for students.
#
# Professor can create/view/modify assignments by going to manage assignment tab in course tools, on the index page of
# each course. He/She can also limit submission from student, can change the type of assignment and submission date if
# required. The assignments will automatically get sorted out based on the course and the task. Student will not be able
# to modify the assignment, only faculty can do this. The assignment could be graded by points/weights/letter, and it
# can be modified in the Course Configuration page.
#
# Generally, a course has many assignments, and each assignments contains many student grades and many submitted deliverables.
#
# * Professor can create an assignment on course assignments index page by clicking the "New Assignment" link.
# * Assignment can be grouped by task_number.
# * Assignment has default scope to get ordered based on task_number and assignment_order
# * assignment_order is auto generated by system, professor cannot directly specify the number of assignment_order. Instead, they can use drag-drop function to reorder them.
# * task_number, due_date, name can be blank
# * maximum_score is a required field. Professor should give a maximum score (>=0 ) for each assignment.
# * is_team_deliverable tells the assignment is a team deliverable or individual deliverable
# * is_submittable is designed for those assignment that don't required any submission, e.g., course participation, effort log.
# * verify_deliverables_submitted tells whether there are any deliverable submmited for this assignment. If so, the professor could not delete this assignment.


class Assignment < ActiveRecord::Base
  attr_accessible :name, :course_id, :maximum_score, :is_team_deliverable, :due_date, :assignment_order, :task_number, :is_submittable, :short_name
  attr_accessor :date, :hour, :minute

  validates :maximum_score, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates_presence_of :course_id
  validates_inclusion_of :is_team_deliverable, :is_submittable, :in => [true, false]

  belongs_to :course
  has_many :grades
  has_many :deliverables

  before_destroy :verify_deliverables_submitted

  acts_as_list :column => "assignment_order", :scope => [:course_id]
  default_scope :order => 'assignment_order ASC'

  def name_with_type
    unless self.course.grading_rule.nil?
      nomenclature = self.course.nomenclature_assignment_or_deliverable.capitalize
    else
      nomenclature = "deliverable"
    end

    if self.task_number.blank?
      task = ""
    else
      task = "Task #{self.task_number}. "
    end

    if self.is_team_deliverable?
      task + self.name + " (Team " + nomenclature + ")"
    else
      task + self.name + " (Individual " + nomenclature + ")"
    end
  end

  # To check whether the deliverable is submitted or not.
  def verify_deliverables_submitted
    self.deliverables.size <= 0
  end

  # To get the list of deliverables submitted by the student.
  def get_student_deliverable student_id
    if self.is_team_deliverable?
      team = User.find(student_id).teams.find_by_course_id(self.course_id)
      unless team.nil?
        self.deliverables.find_by_team_id(team.id)
      end
    else
      self.deliverables.find_by_creator_id(student_id)
    end
  end

  # To get the student grade for an assignment.
  def get_student_grade student_id
    Grade.get_grade(self.course.id, self.id, student_id)
  end

  def formatted_maximum_score
    if self.course.nil? || self.course.grading_rule.nil? || self.course.grading_rule.grade_type=="points"
      self.maximum_score.to_s
    else
      "100"
    end
  end

  # To get list of all the assignments for the student from the courses he has registered.
  def self.list_assignments_for_student student_id, type= :all
    student = User.find(student_id)
    courses = case type
                when :all
                  student.registered_courses
                when :current
                  student.registered_for_these_courses_during_current_semester
                when :past
                  student.registered_for_these_courses_during_past_semesters
              end
    assignments = Assignment.unscoped.find_all_by_course_id(courses.map(&:id), :order => "course_id ASC, id ASC")
  end

  #Re-position: change the sequence of Assignments
  def self.reposition(ids)
    update_all(["assignment_order = STRPOS(?, ','||id||',')", ",#{ids.join(',')},"], {:id => ids})
  end

  def set_due_date date, hour, minute
    self.date = date
    self.hour = hour
    self.minute = minute

    if self.date.blank?
      self.due_date = nil
      return
    end

    if self.hour.blank?
      self.hour = "22"
      self.minute = "0"
    end

    if self.minute.blank?
      self.minute = "0"
    end

    self.due_date = "#{self.date} #{self.hour}:#{self.minute}"
  end

  def self.fetch_submittable_assignments_by_course_id course_id
    Assignment.where(:course_id => course_id, :is_submittable => 't').order('id ASC')
  end

end
