task default: %w[test]

task :test do
  ENV['dryrun'] = 'true'
  ruby "test/unittest.rb"
end
