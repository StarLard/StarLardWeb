# frozen_string_literal: true

# Checks the parts of the built site that html-proofer can't see: the data that drives the home page,
# the redirects in firebase.json, and the feed and sitemap. Run with `bundle exec rake test`, which builds first.

require "minitest/autorun"
require "json"
require "yaml"
require "date"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ROOT = File.expand_path("..", __dir__)
SITE = File.join(ROOT, "_site")

def read_site(path)
  File.read(File.join(SITE, path))
end

# Like assert_includes, but the failure message doesn't print the whole page.
module PageAssertions
  def assert_contains(page, text, message)
    assert page.include?(text), message
  end

  def refute_contains(page, text, message)
    refute page.include?(text), message
  end
end
Minitest::Test.include(PageAssertions)

def post_front_matter(path)
  YAML.safe_load(File.read(path).split(/^---\s*$/, 3)[1], permitted_classes: [Date, Time])
end

class AppsTest < Minitest::Test
  def setup
    @apps = YAML.safe_load_file(File.join(ROOT, "_data/apps.yml"))
    @home = read_site("index.html")
  end

  def test_every_app_has_the_required_fields
    @apps.each do |app|
      %w[name url icon platforms pitch].each do |field|
        refute_empty app[field].to_s, "#{app["name"] || "An app"} is missing #{field}"
      end
      assert_match %r{\Ahttps://}, app["url"], "#{app["name"]} should link to an https site"
    end
  end

  def test_exactly_one_app_is_featured
    featured = @apps.select { |app| app["featured"] }
    assert_equal 1, featured.size, "Mark exactly one app `featured: true` in _data/apps.yml"
    app = featured.first
    %w[image image_alt action].each do |field|
      refute_empty app[field].to_s, "The featured app #{app["name"]} is missing #{field}"
    end
  end

  def test_every_app_image_exists
    @apps.each do |app|
      [app["icon"], app["image"]].compact.each do |path|
        assert File.exist?(File.join(ROOT, path)), "#{app["name"]} points to #{path}, which doesn't exist"
      end
    end
  end

  def test_every_app_appears_on_the_home_page
    @apps.each do |app|
      assert_contains @home, %(href="#{app["url"]}"), "#{app["name"]} isn't linked from the home page"
    end
  end

  def test_the_featured_app_gets_the_wide_card
    featured = @apps.find { |app| app["featured"] }
    card = @home[/<article class="sl-card sl-card--feature">.*?<\/article>/m]
    refute_nil card, "The home page has no featured app card"
    assert_contains card, featured["name"], "The featured card should show #{featured["name"]}"
  end
end

class HomePageTest < Minitest::Test
  def setup
    @home = read_site("index.html")
  end

  def test_has_every_section_the_nav_links_to
    nav = YAML.safe_load_file(File.join(ROOT, "_data/navigation.yml"))["main"]
    nav.each do |link|
      anchor = link["url"].split("#", 2)[1]
      next unless anchor

      assert_contains @home, %(id="#{anchor}"), "The nav links to ##{anchor}, but the home page has no such section"
    end
  end

  def test_lists_every_experience_entry
    YAML.safe_load_file(File.join(ROOT, "_data/experience.yml")).each do |item|
      assert_contains @home, item["title"].gsub("&", "&amp;"), "Experience entry #{item["title"]} is missing"
    end
  end

  def test_sets_the_theme_before_the_page_draws
    head = @home[/<head>.*?<\/head>/m]
    theme_script = head.index("sl-theme")
    stylesheet = head.index("main.css")
    refute_nil theme_script, "The inline theme script is missing from <head>"
    assert theme_script < stylesheet, "The theme script should run before the stylesheet loads"
  end

  # Browsers keep CSS and JS for an hour, so each build needs new URLs or visitors see old styles.
  def test_stylesheet_and_script_urls_change_every_build
    assert_match %r{href="/assets/css/main\.css\?v=\d+"}, @home, "main.css needs a ?v= build version"
    assert_match %r{src="/assets/js/theme\.js\?v=\d+"}, @home, "theme.js needs a ?v= build version"
  end

  def test_has_the_theme_picker
    %w[auto light dark].each do |value|
      assert_contains @home, %(name="theme" value="#{value}"), "The theme picker is missing #{value}"
    end
  end
end

class PostsTest < Minitest::Test
  POSTS = Dir[File.join(ROOT, "_posts", "*.md")].sort

  def test_there_are_posts
    refute_empty POSTS
  end

  def test_every_post_has_a_title_date_and_description
    POSTS.each do |path|
      front = post_front_matter(path)
      name = File.basename(path)
      %w[title date description].each do |field|
        refute_empty front[field].to_s, "#{name} is missing #{field}"
      end
    end
  end

  def test_every_post_is_built_at_its_permalink
    POSTS.each do |path|
      slug = File.basename(path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
      assert File.exist?(File.join(SITE, "posts", slug, "index.html")), "#{slug} wasn't built at /posts/#{slug}/"
    end
  end

  def test_the_posts_page_lists_every_post
    index = read_site("posts/index.html")
    POSTS.each do |path|
      slug = File.basename(path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
      assert_contains index, %(href="/posts/#{slug}/"), "/posts/ doesn't list #{slug}"
    end
  end
end

class FeedAndSitemapTest < Minitest::Test
  def test_the_feed_includes_every_post
    feed = read_site("feed.xml")
    Dir[File.join(ROOT, "_posts", "*.md")].each do |path|
      title = post_front_matter(path)["title"]
      assert_contains feed, title, "The feed is missing #{title}"
    end
  end

  def test_the_sitemap_lists_the_home_and_posts_pages
    sitemap = read_site("sitemap.xml")
    assert_contains sitemap, "<loc>https://starlard.dev/</loc>", "The sitemap is missing the home page"
    assert_contains sitemap, "<loc>https://starlard.dev/posts/</loc>", "The sitemap is missing /posts/"
    refute_contains sitemap, "404", "The sitemap shouldn't list the 404 page"
  end

  def test_pages_have_a_social_preview_image
    assert read_site("index.html").match?(%r{<meta property="og:image" content="https://starlard\.dev/[^"]+"}), "The home page has no og:image"
  end
end

class RedirectsTest < Minitest::Test
  REDIRECTS = JSON.parse(File.read(File.join(ROOT, "firebase.json")))["hosting"]["redirects"]

  # Old URLs from the Minimal Mistakes site, and where each should end up.
  EXPECTED = {
    "/portfolio/babedoo/" => "https://babedoo.starlard.dev",
    "/portfolio/hearth-keeper/" => "https://hearthkeeper.starlard.dev",
    "/portfolio/hearth-keeper" => "https://hearthkeeper.starlard.dev",
    "/portfolio/mimeer/" => "https://mimeer.starlard.dev",
    "/portfolio/scooba/" => "https://scooba.starlard.dev",
    "/portfolio/" => "/#apps",
    "/portfolio" => "/#apps",
    "/tags/swift/" => "/posts/",
    "/categories/ios/" => "/posts/",
    "/years/2025/" => "/posts/"
  }.freeze

  def destination_for(path)
    rule = REDIRECTS.find do |redirect|
      if redirect["regex"]
        Regexp.new(redirect["regex"]).match?(path)
      else
        redirect["source"] == path
      end
    end
    rule && rule["destination"]
  end

  def test_old_urls_redirect_where_they_should
    EXPECTED.each do |path, destination|
      assert_equal destination, destination_for(path), "#{path} should redirect to #{destination}"
    end
  end

  def test_current_pages_are_not_redirected
    %w[/ /posts/ /posts/extinguishing-the-hearth/ /404.html].each do |path|
      assert_nil destination_for(path), "#{path} is a live page but matches a redirect"
    end
  end

  def test_redirects_are_permanent
    REDIRECTS.each do |redirect|
      assert_equal 301, redirect["type"], "#{redirect["regex"] || redirect["source"]} should be a 301"
    end
  end

  # Pages must revalidate on every visit so they pick up each deploy's new stylesheet URL.
  def test_pages_are_not_cached
    headers = JSON.parse(File.read(File.join(ROOT, "firebase.json")))["hosting"]["headers"]
    no_cache = headers.find { |rule| rule["headers"].any? { |h| h["key"] == "Cache-Control" && h["value"] == "no-cache" } }
    refute_nil no_cache, "firebase.json should mark pages no-cache"
    pattern = Regexp.new(no_cache["regex"])
    %w[/ /posts/ /posts/extinguishing-the-hearth/ /404.html].each do |path|
      assert_match pattern, path, "#{path} would be cached"
    end
    %w[/assets/css/main.css /assets/js/theme.js /assets/images/star-lard-logo.png].each do |path|
      refute_match pattern, path, "#{path} shouldn't be marked no-cache"
    end
  end

  def test_redirects_point_at_existing_destinations
    REDIRECTS.map { |redirect| redirect["destination"] }.uniq.each do |destination|
      next if destination.start_with?("https://")

      page = destination.split("#", 2).first
      file = page.end_with?("/") ? File.join(SITE, page, "index.html") : File.join(SITE, page)
      assert File.exist?(file), "A redirect points to #{destination}, which isn't built"
    end
  end
end
