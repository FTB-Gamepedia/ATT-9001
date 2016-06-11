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

while true
  params["continue"] = continue
  
  res = CLIENT.post(params)
  
  res["query"]["tiles"].each do |entry|
    tilesheet[entry["name"]] = entry["id"]
    puts "#{entry["name"]}; #{entry["id"]}"
  end
  
  if res["continue"].nil?
    break
  else
    continue = res["continue"]["continue"]
    puts "#{continue}; #{res["continue"]["tsfrom"]}"
    params["tsfrom"] = res["continue"]["tsfrom"]
  end
end

Dir.glob("resources/#{MOD}/*.lang").each do |file|
  code = $languages[file.sub(/resources\/#{MOD}\//, "").sub(/\.lang/, "")]
  puts code
end
