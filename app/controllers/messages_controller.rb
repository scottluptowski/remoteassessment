class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

=begin
=> {"AccountSid"=>"ACa194ec6c151ef1e99bfec90e4836d138",
 "MessageSid"=>"SMf15a4b851e0fa1f00743ff220a1ba088",
 "Body"=>"Patrick number",
 "ToZip"=>"80216",
 "ToCity"=>"DENVER",
 "FromState"=>"CA",
 "ToState"=>"CO",
 "SmsSid"=>"SMf15a4b851e0fa1f00743ff220a1ba088",
 "To"=>"+13036257938",
 "ToCountry"=>"US",
 "FromCountry"=>"US",
 "SmsMessageSid"=>"SMf15a4b851e0fa1f00743ff220a1ba088",
 "ApiVersion"=>"2010-04-01",
 "FromCity"=>"LOS ANGELES",
 "SmsStatus"=>"received",
 "NumMedia"=>"0",
 "From"=>"+12132158528",
 "FromZip"=>"90249",
 "controller"=>"messages",
 "action"=>"test_receive_answer"}
=end

  def new
    @assignments = current_teacher.assignments
    @groups = current_teacher.groups
  end

  # @assignment = Assignment.find(params[:message_to_send][:assignment])
  # sms_content = @assignment.description
  # teacher_number = current_teacher.phone_number.to_i

  # creates an array of group objects
  # groups_to_receive_assessment = params[:message_to_send][:groups].map do |group_id|
  #   Group.find(group_id)
  # end

  # @assignment = Assignment.find(params[:message_to_send][:assignment])
  #   sms_content = @assignment.description
  #   teacher_number = current_teacher.phone_number.to_i

  #   student_phone_numbers_to_text = groups_to_receive_assessment.map do |group|
  #     group.students.map do |student|
  #       student.phone_number.to_i
  #     end
  #   end.flatten

  def send_text_message(sms_content, from, to)
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    @client.account.sms.messages.create(
      :from => "+1#{from}",
      :to => "+1#{to}",
      :body => "#{sms_content}"
    )

    redirect_to teacher_root_path, notice: "You successfully sent the message!"
  end

  def receive_text_message
    student_phone_number = params["From"].slice(2..-1)
    @student = Student.find_by(phone_number: student_phone_number)

    if params["Body"] == "ready"
      # we need to retrieve the next appropriate message to send
      send_text_message
    else
    end
  end

  def test_receive_answer
    binding.pry
    # grab the from field
    # remove the +1 which twilio adds
    # compare to database
    # create an Answer object which belongs to the user
    # with that phone number

    student_phone = params["From"][2..-1].to_i
    student = Student.find_by(:phone_number => student_phone)
    q = student.answers.count + 1
    question = Question.find(q)
    Answer.create(student: student, question: question, response: params["Body"])
    binding.pry


    #raise params
  end

  private
    def message_params
      params.require(:message_to_send).permit(:assignment, :groups => [])
    end
end
