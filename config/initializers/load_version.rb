begin
  yaml_file_path = File.join(Rails.root, 'config', 'version.yml')
  yaml_config = YAML.load_file(yaml_file_path)
  ENV['LARA_VERSION'] = yaml_config['version']
rescue Exception => e
  # no known version
  ENV['LARA_VERSION'] = 'unknown'
end
