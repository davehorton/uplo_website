DROPBOX = YAML.load_file(File.join(Rails.root, "config", "dropbox.yml"))[Rails.env]
Dropbox::API::Config.mode = "sandbox"
