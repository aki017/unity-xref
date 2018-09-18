require "sinatra"
require "json"

get "/query" do
  uid = params["uid"]
  version = params["version"]
  puts "Receive #{uid}"

  path = data(version)[uid]
  if !path.nil?
    return ret(version, uid, path)
  end

  class_name = /^(.*?)(?:`.*)?(?:\(.*\))?$/.match(uid)[1].split(".")[0..-2].join(".")
  m = /^(.*?)(?:`.*)?(?:\(.*\))?$/.match(uid)[1].split(".")[-1]
  puts "class_name: #{class_name}"
  puts "method_name: #{m}"

  path = data(version)[class_name]
  if !path.nil?
    return ret(version, uid, path)
  end

  return "[]"
rescue
  return "[]"
end

def ret(version, uid, filename)
  d = {
    uid: uid,
    name: uid,
    fullName: uid,
    href: "https://docs.unity3d.com/ja/#{version}/ScriptReference/#{filename}",
    tags: ",",
    vendor: nil,
    hash: nil,
    nameWithType: uid,
  }

  return JSON.generate([d])
end

def log(msg)
  File.open("log.log", "a") do |f|
    f.puts msg
  end
end

def data(version)
  @data ||={}
  @data[version] ||= JSON.parse(File.read("json/#{version}.json"))
end
