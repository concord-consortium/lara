class AddStudentReportEnabled < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :student_report_enabled, :boolean, default: true
  end
end
