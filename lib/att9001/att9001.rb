require "mediawiki-butt"
require "yaml"

require_relative "mc2mw"

CONFIG = YAML.load_file("config.yml")

CLIENT = MediaWiki::Butt.new(CONFIG["wiki"])

CLIENT.login(CONFIG["username"], CONFIG["password"])

MOD = CONFIG["mod"]
tilesheet = {} # EN name => id
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
  end

  break unless res["continue"]

  continue = res["continue"]["continue"]
  params["tsfrom"] = res["continue"]["tsfrom"]
end

# Is always based on en_US. Maybe that should be fixed.
base = {}

File.open("resources/#{MOD}/en_US.lang", "r").each do |line|
  prop = line.sub(/=(.+)/, "")
  local = line.sub(/(.+)=/, "")
  
  base[prop] = local if !tilesheet[local].nil?
end

Dir.glob("resources/#{MOD}/*.lang").each do |file|
  break if file == "resources/#{MOD}/en_US.lang"
  LANGUAGES[file.sub(/resources\/#{MOD}\//, "").sub(/\.lang/, "")].each do |code|
    lang_tilesheet = {} # XX name => id (existing tilesheet)
    params = {
      action: "query",
      list: "tiletranslations",
      tslang: code
    }
    
    tilesheet.each do |en_entry, id|
      params["tsid"] = id
      
      res = CLIENT.post(params)
      res["query"]["tiles"].each do |entry|
        lang_tilesheet[entry["display_name"]] = entry["entry_id"]
      end
      
      lang_tilesheet
    end
    
    file.each do |line|
      prop = line.sub(/=(.+)/, "")
      local = line.sub(/(.+)=/, "")
      
      if base[prop] != local
        
      end
    end
  end
end
