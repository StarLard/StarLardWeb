# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StarLardWeb is a static portfolio website built with Jekyll using the Minimal Mistakes theme. It showcases iOS development projects and blog posts. Hosted on Firebase Hosting with automatic deployment via GitHub Actions.

## Common Commands

### Setup
```bash
cat .ruby-version | rbenv install --skip-existing
gem install bundler
bundle install
```

### Development
```bash
# Serve locally with Jekyll (auto-reloads on changes)
bundle exec jekyll serve

# Build site (generates _site directory)
bundle exec jekyll build

# Serve with Firebase emulator (requires build first)
firebase emulators:start --only hosting:starlarddev
```

### Deployment
Automatic deployment occurs on merge to main via GitHub Actions. Manual deploy:
```bash
firebase deploy --only hosting --project dev-starlard-lard-lad
```

## Architecture

- **Theme**: Minimal Mistakes Jekyll theme with dark skin variant
- **Collections**: Posts (`_posts/`) and Portfolio items (`_portfolio/`)
- **Pages**: Static pages in `_pages/`, navigation configured in `_data/navigation.yml`
- **Assets**: Images in `assets/images/`, CSS in `assets/css/`
- **Build output**: `_site/` directory (deployed to Firebase)

## Content Conventions

### Posts
- Location: `_posts/`
- Naming: `YEAR-MONTH-DAY-title.md`
- Required front matter: `layout`, `title`, `date`, `categories`, `tags`

### Portfolio Items
- Location: `_portfolio/`
- Front matter includes: `title`, `date`, `excerpt`, `header.image`, `sidebar`, `gallery`

### Code Snippets in Posts
Use Jekyll's highlight tag:
```
{% highlight swift %}
print("Hello World!")
{% endhighlight %}
```

## Key Configuration

- `_config.yml`: Main Jekyll configuration (requires server restart on changes)
- `firebase.json`: Firebase hosting configuration (public directory: `_site`)
- Theme documentation: https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/
