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
  
  puts "#{prop}; #{local}"
  
  base[prop] = local if !tilesheet[local].nil?
end

puts "########"

Dir.glob("resources/#{MOD}/*.lang").each do |file|
  puts file
  break if file == "resources/#{MOD}/en_US.lang"
  LANGUAGES[file.sub(/resources\/#{MOD}\//, "").sub(/\.lang/, "")].each do |code|
    puts code
    lang_tilesheet = {} # XX name => id (based existing translated tilesheet)
    params = {
      action: "query",
      list: "tiletranslations",
      tslang: code
    }
    
    tilesheet.each do |en_entry, id|
      puts "#{en_entry}; #{id}"
      params["tsid"] = id
      
      res = CLIENT.post(params)
      res["query"]["tiles"].each do |entry|
        lang_tilesheet[entry["display_name"]] = entry["entry_id"]
        puts "#{entry["display_name"]}; #{entry["entry_id"]}"
      end
    end
    
    File.open(file, "r").each do |line|
      prop = line.sub(/=(.+)/, "")
      local = line.sub(/(.+)=/, "")
      
      puts "#{prop}; #{local}"
      
      if base[prop] != local #&& lang_tilesheet[local].nil? issue here && !tilesheet[base[prop]].nil?
        params = {
          action: "translatetile",
          tsid: tilesheet[base[prop]],
          tslang: code,
          tsname: local
        }
        # CLIENT.post(params)
        puts "#{tilesheet[base[prop]]}; #{base[prop]} (#{prop}) => #{local} (#{code})"
      end
    break #debug
    end
  end
end
