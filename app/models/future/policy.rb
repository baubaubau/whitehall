# A model to represent new-world policies that are published by policy-publisher
# and stored in the content-store.
module Future
  class Policy
    attr_reader :base_path, :content_id, :slug, :title

    def initialize(attributes)
      @base_path = attributes["base_path"]
      @content_id = attributes["content_id"]
      @title = attributes["title"]
      @slug = extract_slug
    end

    def self.find(content_id)
      if attributes = find_entry(content_id)
        new(attributes)
      end
    end

    def self.all
      entries.map { |attrs| new(attrs) }
    end

    def topics
      []
    end

  private

    def extract_slug
      base_path.split('/').last
    end

    def self.find_entry(content_id)
      entries.find { |p| p["content_id"] == content_id }
    end

    def self.entries
      content_register.entries("policy")
    end

    def self.content_register
      @content_register ||= Whitehall.content_register
    end
  end
end
