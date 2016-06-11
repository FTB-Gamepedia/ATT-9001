require "mediawiki-butt"
require "yaml"

require_relative "mc2mw"

CONFIG = YAML.load_file("config.yml")

CLIENT = MediaWiki::Butt.new(CONFIG["wiki"])

CLIENT.login(CONFIG["username"], CONFIG["password"])

MOD = CONFIG["mod"]
tilesheet = {} # name => id
continue = ""

params = {
  action: "query",
  list: "tiles",
  tsmod: MOD,
  tslimit: "max"
}

loop do
  params["continue"] = continue
  
  res = CLIENT.post(params)
  
  res["query"]["tiles"].each do |entry|
    tilesheet[entry["name"]] = entry["id"]
    puts "#{entry["name"]}; #{entry["id"]}"
  end

  break unless res["continue"]

  continue = res["continue"]["continue"]
  puts "#{continue}; #{res["continue"]["tsfrom"]}"
  params["tsfrom"] = res["continue"]["tsfrom"]
end

Dir.glob("resources/#{MOD}/*.lang").each do |file|
  code = LANGUAGES[file.sub(/resources\/#{MOD}\//, "").sub(/\.lang/, "")]
  puts code
end
