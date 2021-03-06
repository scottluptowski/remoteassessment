class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new
    @assignments = current_teacher.assignments.where(sent_at: nil)
    @groups = current_teacher.groups
  end

  def create
    # example params: "message_to_send" => {"assignment"=>"1", "groups"=>["1"]}
    # create a new row in the student_assignments table
    @assignment = Assignment.find(params[:message_to_send][:assignment])

    # update datetime_to_send
    @assignment.datetime_to_send = "#{params[:message_to_send][:date]} #{params[:message_to_send][:time]}"
    @assignment.save

    # officially assign all of the students the assessment
    groups_to_receive_assignment = params[:message_to_send][:group_ids].map do |group_id|
      Group.find(group_id)
    end

    # set group assignment associations
    groups_to_receive_assignment.each do |group|
      group.group_assignments.create(assignment: @assignment) if group.group_assignments.where(assignment: @assignment).empty?
    end

    # returns an array of student objects
    students_assigned_assignment = groups_to_receive_assignment.map do |group|
      group.students.map do |student|
        student
      end
    end.flatten

    # for each student build a row in the join table with the appropriate assignment_id
    students_assigned_assignment.each do |student|
      student.student_assignments.build(assignment: @assignment)
      student.save
    end

    # creates all of the respective messages to be sent in the messages table
    students_assigned_assignment.each do |student|

    end
    redirect_to teacher_root_path
  end

  def receive_text_message
    AssignmentResponseHandler.run(params["From"], params["To"], params["Body"])

    render :nothing => true
  end

  private
    def message_params
      params.require(:message_to_send).permit(:assignment, :group_ids => [])
    end
end
