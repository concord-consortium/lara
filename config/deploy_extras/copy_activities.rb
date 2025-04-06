puts "loading lara tasks"

def ssh_login
  "#{user}@#{domain}"
end
def open_ssh_mysql(host="127.0.0.1")
  set :db_tunnel_proc, Process.spawn("ssh -Ng -L 3307:#{host}:3306 #{ssh_login}")
  sleep 1
  puts "opened mysql forwarding agent"
end
def close_ssh_mysql
  sleep 1
  Process.kill("HUP",db_tunnel_proc)
  Process.wait(db_tunnel_proc)
  puts "closed mysql forwarding agent"
end


namespace :lara do
  task :copy_data, roles: :db do
    timestamp = Time.now.strftime "%Y-%m-%d"
    filename  = "#{timestamp}-lara.sql"

    text      = capture "cat #{deploy_to}/shared/config/database.yml"
    conf = Psych.safe_load(text, permitted_classes: [Hash, String])["production"]
    passwd    = conf["password"]
    user      = conf["username"]
    database  = conf["database"]
    host      = conf["host"]
    open_ssh_mysql(host)

    on_rollback { run "rm #{filename}" }
    db_url    = "mysqldump --host=127.0.0.1 --port=3307 -u #{user} -p#{passwd} #{database}"
    puts "writing database structure"
    %x[ #{db_url} --no-data > #{filename}]
    puts "adding users data"
    %x[ #{db_url} -t users -w"email NOT LIKE 'no-email-%'" >> #{filename}]

    puts "adding other data"
    %w[ embeddable_image_questions embeddable_multiple_choice_choices embeddable_multiple_choices embeddable_open_responses
    embeddable_xhtmls image_interactives interactive_pages interactive_items lightweight_activities lightweight_activities_sequences
    mc_answer_choices mw_interactives page_items projects schema_migrations sequences themes video_interactives video_sources
    ].each do |table|
      %x[ #{db_url} -t #{table} >> #{filename}]
    end
    close_ssh_mysql
  end
end
