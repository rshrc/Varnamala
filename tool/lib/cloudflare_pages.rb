# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# A small client for the parts of the Cloudflare Pages API the Katha tools
# use: projects and their deployments. Uploading files is left to Wrangler,
# which speaks Pages' content-addressed upload protocol and only sends what
# changed; see CloudflarePages#deploy.
#
# Credentials come from the environment, never from a file in the repo:
#
#   CLOUDFLARE_API_TOKEN   an account token with "Cloudflare Pages: Edit"
#   CLOUDFLARE_ACCOUNT_ID  the account it belongs to
class CloudflarePages
  API = 'https://api.cloudflare.com/client/v4'

  # Wrangler is pinned, so a deploy behaves the same next month as today.
  WRANGLER = 'wrangler@4.162.0'

  class Error < StandardError; end

  def self.from_env
    token = ENV.fetch('CLOUDFLARE_API_TOKEN') { raise Error, 'CLOUDFLARE_API_TOKEN is not set' }
    account = ENV.fetch('CLOUDFLARE_ACCOUNT_ID') { raise Error, 'CLOUDFLARE_ACCOUNT_ID is not set' }
    new(token: token, account: account)
  end

  def initialize(token:, account:)
    @token = token
    @account = account
  end

  # Every Pages project on the account, by name.
  def projects
    get("/accounts/#{@account}/pages/projects").to_h { |project| [project['name'], project] }
  end

  def project(name)
    get("/accounts/#{@account}/pages/projects/#{name}")
  rescue Error => e
    raise unless e.message.include?('404') || e.message.downcase.include?('not found')

    nil
  end

  # Creates [name] if it does not exist yet. Returns the project either way.
  def ensure_project(name, branch: 'main')
    project(name) || post(
      "/accounts/#{@account}/pages/projects",
      { name: name, production_branch: branch },
    )
  end

  def latest_deployment(name)
    get("/accounts/#{@account}/pages/projects/#{name}/deployments", per_page: 1).first
  end

  # Uploads [dir] as a new production deployment of [name]. Wrangler hashes
  # every file and uploads only those the project has not seen, so pushing
  # again after recording ten new lines sends ten files, not three thousand.
  #
  # A dropped connection part-way through is retried: the files that made it
  # are not sent again, so each attempt only finishes what the last one left.
  def deploy(name, dir, branch: 'main', message: nil, attempts: 4)
    command = [
      'npx', '--yes', WRANGLER, 'pages', 'deploy', dir,
      "--project-name=#{name}", "--branch=#{branch}", '--commit-dirty=true'
    ]
    command << "--commit-message=#{message}" if message
    env = { 'CLOUDFLARE_API_TOKEN' => @token, 'CLOUDFLARE_ACCOUNT_ID' => @account }
    attempts.times do |attempt|
      # Run from the staged folder, so Wrangler does not mistake the repo's
      # own functions/ directory for Pages Functions.
      return true if system(env, *command, chdir: dir)

      wait = 5 * (2**attempt)
      warn "wrangler deploy of #{name} failed; retrying in #{wait}s (#{attempt + 1}/#{attempts})"
      sleep wait
    end
    raise Error, "wrangler deploy of #{name} failed after #{attempts} attempts"
  end

  private

  def get(path, query = {})
    request(Net::HTTP::Get, path, query: query)
  end

  def post(path, body)
    request(Net::HTTP::Post, path, body: body)
  end

  def request(kind, path, query: {}, body: nil)
    uri = URI("#{API}#{path}")
    uri.query = URI.encode_www_form(query) unless query.empty?
    req = kind.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    if body
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(body)
    end
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 60) { |http| http.request(req) }
    json = JSON.parse(res.body)
    return json['result'] if json['success']

    messages = Array(json['errors']).map { |e| "#{e['code']} #{e['message']}" }.join('; ')
    raise Error, "#{res.code} #{kind::METHOD} #{path}: #{messages}"
  end
end
