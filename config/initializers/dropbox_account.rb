DROPBOX = YAML.load_file(File.join(Rails.root, "config", "dropbox.yml"))[Rails.env]
Dropbox::API::Config.app_key = 'l0rj7yhvm6f0jtj'
Dropbox::API::Config.app_secret = 'spmfic5xcltg06i'
Dropbox::API::Config.mode = "sandbox"
