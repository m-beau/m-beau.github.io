require 'httparty'
require 'json'
require 'fileutils'
require 'jekyll'

# Fetches repo metadata (description, language, stars, forks, issues,
# contributors, license) from the GitHub REST API for every entry in
# _data/repositories.yml[github_repos] and attaches it as a `stats` hash
# on that entry. Results are cached on disk for CACHE_TTL seconds so that
# jekyll --watch / livereload doesn't re-hit the API on every rebuild.
#
# Uses GITHUB_TOKEN from the environment when present (5000 req/hr in CI
# instead of the 60 req/hr unauthenticated limit).
module GithubStats
  class Generator < Jekyll::Generator
    safe true
    priority :high

    CACHE_DIR = '.jekyll-cache/github_stats'.freeze
    CACHE_TTL = 3600 # seconds

    def generate(site)
      repos = site.data.dig('repositories', 'github_repos')
      return unless repos.is_a?(Array)

      FileUtils.mkdir_p(CACHE_DIR)

      repos.each do |entry|
        next unless entry.is_a?(Hash)
        path = entry['repo']
        next unless path.is_a?(String) && path.include?('/')

        stats = load_cached(path) || fetch_fresh(path)
        entry['stats'] = stats if stats
      end
    end

    private

    def headers
      h = {
        'User-Agent' => 'jekyll-m-beau-site',
        'Accept'     => 'application/vnd.github+json',
      }
      token = ENV['GITHUB_TOKEN']
      h['Authorization'] = "Bearer #{token}" if token && !token.empty?
      h
    end

    def cache_path(repo_path)
      File.join(CACHE_DIR, "#{repo_path.gsub('/', '_')}.json")
    end

    def load_cached(repo_path)
      file = cache_path(repo_path)
      return nil unless File.exist?(file)
      return nil if (Time.now - File.mtime(file)) > CACHE_TTL
      JSON.parse(File.read(file))
    rescue StandardError
      nil
    end

    def save_cached(repo_path, stats)
      File.write(cache_path(repo_path), JSON.generate(stats))
    rescue StandardError => e
      Jekyll.logger.warn('GitHub stats:', "cache write failed for #{repo_path}: #{e.message}")
    end

    def fetch_fresh(repo_path)
      Jekyll.logger.info('GitHub stats:', "fetching #{repo_path}")
      repo_url = "https://api.github.com/repos/#{repo_path}"
      res = HTTParty.get(repo_url, headers: headers, timeout: 10)

      unless res.code == 200
        Jekyll.logger.warn('GitHub stats:', "#{repo_path} -> HTTP #{res.code}")
        return load_stale(repo_path)
      end

      data = res.parsed_response
      stats = {
        'description'  => data['description'],
        'language'     => data['language'],
        'stars'        => data['stargazers_count'],
        'forks'        => data['forks_count'],
        'issues'       => data['open_issues_count'],
        'license'      => data.dig('license', 'spdx_id'),
        'contributors' => fetch_contributor_count(repo_path),
      }
      save_cached(repo_path, stats)
      stats
    rescue StandardError => e
      Jekyll.logger.warn('GitHub stats:', "#{repo_path} failed: #{e.message}")
      load_stale(repo_path)
    end

    # Uses the Link header pagination trick: with per_page=1 the total
    # number of contributors equals the last page number.
    def fetch_contributor_count(repo_path)
      url = "https://api.github.com/repos/#{repo_path}/contributors?per_page=1&anon=0"
      res = HTTParty.get(url, headers: headers, timeout: 10)
      return nil unless res.code == 200

      link = res.headers['link']
      if link && (m = link.match(/<[^>]*[?&]page=(\d+)[^>]*>;\s*rel="last"/))
        m[1].to_i
      else
        # No 'last' link means there's only 0 or 1 contributor.
        Array(res.parsed_response).size
      end
    rescue StandardError
      nil
    end

    # Fall back to whatever is on disk (even if stale) when a fetch fails,
    # so a transient API hiccup doesn't blank out the repo cards.
    def load_stale(repo_path)
      file = cache_path(repo_path)
      return nil unless File.exist?(file)
      JSON.parse(File.read(file))
    rescue StandardError
      nil
    end
  end
end
