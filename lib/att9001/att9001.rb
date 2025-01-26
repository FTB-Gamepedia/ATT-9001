require 'mediawiki-butt'
require 'json'
require 'yaml'

require_relative 'mc2mw'

CONFIG = YAML.load_file('config.yml')

CLIENT = MediaWiki::Butt.new(CONFIG['wiki'])

CLIENT.login(CONFIG['login'], CONFIG['token'])

MOD = ARGV[0]

REMOVE_SPACES = ARGV.length > 1 # TODO: be less hacky

# TODO: better names
PROP_REGEX = !REMOVE_SPACES ? /(.+)=(.+)\n/ : /(.+) = (.+)\n/
RIGHT_PROP_REGEX = !REMOVE_SPACES ? /=(.+)\n/ : / = (.+)\n/
LEFT_PROP_REGEX = !REMOVE_SPACES ? /(.+)=/ : /(.+) = /

tilesheet = {} # EN name => id
continue = ''

params = {
  action: 'query',
  list: 'tiles',
  tsmod: MOD,
  tslimit: 'max'
}

loop do
  params['continue'] = continue

  res = CLIENT.post(params)

  res['query']['tiles'].each do |entry|
    tilesheet[entry['name']] = entry['id']
  end

  break unless res['continue']

  continue = res['continue']['continue']
  params['tsfrom'] = res['continue']['tsfrom']
end

# Is always based on en_US. Maybe that should be changed.
base = {} # prop => en local

dot_lang_file_location = "resources/#{MOD}/en_US.lang"
# Checking for the rare uncapitalized file name, which was used in maybe two Minecraft versions
dot_lang_file_location = "resources/#{MOD}/en_us.lang" if !File.file?(dot_lang_file_location)
# Checking for "properties" file name, which is used in some old versions (but is the same format)
dot_lang_file_location = "resources/#{MOD}/en_US.properties" if !File.file?(dot_lang_file_location)

if File.file?(dot_lang_file_location)
  File.open(dot_lang_file_location, 'r').each do |line|
    next if line.match(PROP_REGEX).nil?
    prop = line.sub(RIGHT_PROP_REGEX, '')
    localization = line.sub(LEFT_PROP_REGEX, '').sub(/\r/, '').sub(/\n/, '')

    base[prop] = localization unless tilesheet[localization].nil?
  end
else # assume json
  JSON.parse(File.read("resources/#{MOD}/en_us.json")).each do |prop, localization|
    base[prop] = localization
  end
end

TOKEN = CLIENT.post({action: 'query', meta: 'tokens'})['query']['tokens']['csrftoken'] #TODO: maybe fix MW butt

#################################################
# *.lang files
##################################################
Dir.glob("resources/#{MOD}/*.{lang,properties}").each do |file|
  next if file == "resources/#{MOD}/en_US.lang" || file == "resources/#{MOD}/en_us.lang" || file == "resources/#{MOD}/en_US.properties"

  mc_code = file.sub(/resources\/#{MOD}\/([\w_]+)\.(lang|properties)/, '\1').downcase
  langs = LANGUAGES[mc_code]

  if langs.nil?
      puts "ATT-9001 does not support the language with the code \"#{mc_code}.\""
      puts "Please remove that language file or update mc2mw.rb (and/or report the issue on GitHub)."
      exit
  end

  langs.each do |code|
    puts "Translating Minecraft language #{mc_code} to MediaWiki language #{code}"
    lang_tilesheet = {} # XX name => id (based existing translated tilesheet)
    params = {
      action: 'query',
      list: 'tiletranslations',
      tslang: code
    }

    tilesheet.each do |en_entry, id|
      params['tsid'] = id

      res = CLIENT.post(params)
      res['query']['tiles'].each do |entry|
        lang_tilesheet[entry['display_name']] = entry['entry_id']
      end
    end

    File.open(file, 'r').each do |line|
      next if line.match(PROP_REGEX).nil?
      prop = line.sub(RIGHT_PROP_REGEX, '')
      localization = line.sub(LEFT_PROP_REGEX, '').sub(/\r/, '').sub(/\n/, '')

      if base[prop] != localization && lang_tilesheet[localization].nil? && !tilesheet[base[prop]].nil?
        params = {
          action: 'translatetile',
          tstoken: TOKEN,
          tsid: tilesheet[base[prop]],
          tslang: code,
          tsname: localization
        }

        puts "#{tilesheet[base[prop]]}; #{base[prop]} (#{prop}) => #{localization} (#{code})"
        CLIENT.post(params)
      end
    end
  end
end

#################################################
# *.json files
##################################################
Dir.glob("resources/#{MOD}/*.json").each do |file|
  next if file == "resources/#{MOD}/en_us.json"

  mc_code = file.sub(/resources\/#{MOD}\/([\w_]+)\.json/, '\1').downcase
  langs = LANGUAGES[mc_code]

  if langs.nil?
    puts "ATT-9001 does not support the language with the code \"#{mc_code}.\""
    puts "Please remove that language file or update mc2mw.rb (and/or report the issue on GitHub)."
    exit
  end

  langs.each do |code|
    puts "Translating Minecraft language #{mc_code} to MediaWiki language #{code}"
    lang_tilesheet = {} # XX name => id (based existing translated tilesheet)
    params = {
        action: 'query',
        list: 'tiletranslations',
        tslang: code
    }

    tilesheet.each do |en_entry, id|
      params['tsid'] = id

      res = CLIENT.post(params)
      res['query']['tiles'].each do |entry|
        lang_tilesheet[entry['display_name']] = entry['entry_id']
      end
    end

    JSON.parse(File.read(file)).each do |prop, localization|
      if base[prop] != localization && lang_tilesheet[localization].nil? && !tilesheet[base[prop]].nil?
        params = {
            action: 'translatetile',
            tstoken: TOKEN,
            tsid: tilesheet[base[prop]],
            tslang: code,
            tsname: localization
        }

        puts "#{tilesheet[base[prop]]}; #{base[prop]} (#{prop}) => #{localization} (#{code})"
        CLIENT.post(params)
      end
    end
  end
end
