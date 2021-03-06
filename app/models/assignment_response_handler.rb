class AssignmentResponseHandler

  def self.run(from, to, body)
    student_phone_number = from.slice(2..-1)
    student = Student.find_by(phone_number: student_phone_number)

    teacher_phone_number = to.slice(2..-1)
    teacher = Teacher.find_by(phone_number: teacher_phone_number)
    # Retrieve assignments only for respective teacher
    teacher_assignment_ids = teacher.assignments.map do |assignment|
      assignment.id
    end

    if student.resetting_assignment
      student.resume_assignment(body, teacher_assignment_ids)
      student.send_current_question!
    elsif student.starting_an_assignment?(body)
      student.set_current_question
      student.send_current_question!
    elsif student.asking_for_assignments?(body)
      if student.has_incomplete_assignments?(teacher_assignment_ids)
        student.send_incomplete_assignments!(teacher_assignment_ids)
      else
        student.send_no_assignments_message!(teacher_phone_number)  
      end
    else
      student.record_answer(body)
      student.send_next_question!
    end
  end
end


# if current_assignment is nil (current_question should also be nil)
# then we should send back the list of outstanding assignments for
# that student. student can text back which assignment they want
# to complete. set the respective current_assignment. retrieve
# all of the answers recorded for that respective assignment.
# send the next question.

# screen_response (checks to see if current_assignment is nil)
# check if response is setting an assignment (flag in student table?)
# set the current_assignment
# otherwise send_assignment_list
# if current_assignment is not nil
# record_answer
# send_next_question
