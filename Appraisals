appraise "rails-7-2" do
  gem "rails", "~> 7.2.0"
end

appraise "rails-8-0" do
  gem "rails", "~> 8.0.0"
  # Active Support 8.0.5.1 passes quirks_mode: to JSON.generate and JSON.parse, which
  # json 3 rejects. Fixed on 8-0-stable (rails/rails@2786de26c6); drop this once a
  # Rails 8.0 release carries it.
  gem "json", "< 3"
end

appraise "rails-8-1" do
  gem "rails", "~> 8.1.0"
end

appraise "rails-edge" do
  gem "rails", github: "rails/rails", branch: "main"
end
