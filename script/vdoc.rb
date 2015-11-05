#!/usr/bin/env ruby
require 'pty'

def import_db(name="lara.sql")
  command = "run mysql -uroot -p\$MYSQL_ROOT_PASSWORD lara_production < #{name}"
  puts command
  do_command command
end

def run_test
  do_command "run app script/docker-test.sh"
end

def up
  do_command "up"
end

def do_command cmd
  command = %Q[vagrant ssh -c "cd /lara && docker-compose #{cmd}"]
  puts command
  PTY.spawn(command) do |output, input, pid|
    buffer = ""
    while buffer = output.gets
      printf buffer
    end
  end
end

def help
  puts <<-EOF
    vodc: run a docker command in the vagrant VM.
    usage: vdoc <command> <args>
    command is one of:
      "up" -- boot up the containers using `docker-compose up`
      "importdb <filename.sql>"  -- import the data from `filename.sql`
      "test" -- run guard in a container
      "cmd <command>" -- run some other `docker-compose` command.
  EOF
end


case ARGV[0]
when "importdb"
  filename = ARGV[1]
  import_db filename
when "test"
  run_test
when "up"
  up
when "cmd"
  cmd=ARGV.slice(1..-1).join " "
  do_command cmd
else
  help
end
