source 'https://rubygems.org'

gem 'fastlane'
gem 'cocoapods'
gem 'git-remote-parser'

# Workaround for https://github.com/postmodern/digest-crc/issues/18.
gem 'rake'

# Since we have a GitHub Actions workflow to automatically check for updates,
# it is reasonable to disable Fastlane self-update checks. We can't do it in
# Fastfile because updater initializes before that.
ENV['FASTLANE_SKIP_UPDATE_CHECK'] = '1'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
