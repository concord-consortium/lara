class AddStudentReportEnabled < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :student_report_enabled, :boolean, default: true
  end
end
