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
    puts "#{entry["name"]} => #{entry["id"]}"
  end

  break unless res["continue"]

  continue = res["continue"]["continue"]
  params["tsfrom"] = res["continue"]["tsfrom"]
end

puts tilesheet["Armor Forge"]

# Is always based on en_US. Maybe that should be changed.
base = {} # prop => en local

File.open("resources/#{MOD}/en_US.lang", "r").each do |line|
  next if line.match(/(.+)=(.+)\n/).nil?
  prop = line.sub(/=(.+)\n/, "")
  local = line.sub(/(.+)=/, "").sub(/\n/, "")
  puts "#{prop} => #{local}"
  puts "1 #{local}"
  puts "2 #{tilesheet[local]}" #Returns nil every damn time.
  puts "3 #{tilesheet["Armor Forge"]}" #Returns 201413
  puts "#{!tilesheet[local].nil?} cause #{tilesheet[local]}"
  
  base[prop] = local if !tilesheet[local].nil?
  puts "#{base[prop]} => #{local}" if !tilesheet[local].nil?
end

exit #debug

TOKEN = CLIENT.post({action: "query", meta: "tokens"})["query"]["tokens"]["csrftoken"] #TODO: maybe fix MW butt

Dir.glob("resources/#{MOD}/*.lang").each do |file|
  puts file
  next if file == "resources/#{MOD}/en_US.lang"
  LANGUAGES[file.sub(/resources\/#{MOD}\//, "").sub(/\.lang/, "")].each do |code|
    puts code
    lang_tilesheet = {} # XX name => id (based existing translated tilesheet)
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
        puts "#{entry["display_name"]} => #{entry["entry_id"]}"
      end
    end
    
    puts "#############"
    
    File.open(file, "r").each do |line|
      next if line.match(/(.+)=(.+)\n/).nil?
      prop = line.sub(/=(.+)\n/, "")
      local = line.sub(/(.+)=/, "").sub(/\n/, "")
      puts line
      puts "#{prop} => #{local}"
      puts "Is differect from original: #{base[prop] != local}"
      puts "Tilesheet does not have translated: #{lang_tilesheet[local].nil?}"
      puts "Tilesheet supports translation: #{!tilesheet[base[prop]].nil?}"
      
      #puts "#{prop} => #{local}; #{base[prop] != local}; #{lang_tilesheet[local].nil?}; #{!tilesheet[base[prop]].nil?}"
      
      if base[prop] != local && lang_tilesheet[local].nil? && !tilesheet[base[prop]].nil?
        params = {
          action: "translatetile",
          tstoken: TOKEN,
          tsid: tilesheet[base[prop]],
          tslang: code,
          tsname: local
        }
        
        puts "#{tilesheet[base[prop]]}; #{base[prop]} (#{prop}) => #{local} (#{code})"
        # CLIENT.post(params)
      end
    end
  end
end
