# frozen_string_literal: true

require "rake/testtask"

# Read the built pages as UTF-8 even when the shell locale is ASCII (CI runners, some terminals).
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

SITE_DIR = "_site"

desc "Build the site into #{SITE_DIR}"
task :build do
  sh "bundle exec jekyll build"
end

desc "Check the built site for broken internal links, missing images and bad HTML"
task proof: :build do
  require "html-proofer"

  HTMLProofer.check_directory(
    SITE_DIR,
    # External sites (App Store, LinkedIn) often block automated checks; check internal links only.
    disable_external: true,
    check_internal_hash: true,
    # The feed and sitemap aren't pages.
    ignore_files: [%r{/feed\.xml$}, %r{/sitemap\.xml$}],
    log_level: :info
  ).run
end

Rake::TestTask.new(site_tests: :build) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

desc "Build the site, check its pages, and run the site tests"
task test: %i[proof site_tests]

task default: :test
