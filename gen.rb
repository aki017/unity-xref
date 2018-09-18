require "json5"
require "active_support/all"
require "open-uri"

class TocParser
  def initialize(version)
    @version = version
  end

  def toc_url
    "https://docs.unity3d.com/#{@version}/Documentation/ScriptReference/docdata/toc.json"
  end

  def detail_url(name)
    "https://docs.unity3d.com/#{@version}/Documentation/ScriptReference/#{name}"
  end


  def data
    @data ||= JSON5.parse open(toc_url).read
  end

  def info
    @info unless @info.nil?
    @info ||= {}

    data["children"].each do |e|
      parse_namespace e
    end
    @info
  end

  def parse_namespace(obj)
    $stderr.puts "namespace #{obj["title"]}"
    obj["children"].each do |c|
      pr c, obj["title"]
    end
  end

  def parse_classes(obj, namespace)
    obj["children"].each do |c|
      $stderr.puts "    class #{namespace}.#{c["title"]}"
      @info["#{namespace}.#{c["title"]}"] = c["link"]+".html"
    end
  end

  def pr(obj, namespace)
    if obj["title"] == "Classes" || obj["title"] == "Interfaces"
      parse_classes obj, namespace
    elsif obj["children"]&.any?{|child| %w(Classes Interfaces).include?(child["title"])}
      parse_namespace obj
    else
    end
  end

  def get(name)
    content = open(detail_url(name)).read.force_encoding("UTF-8")
    hash = {}
    content.scan %r{<td class="lbl"><a href="(.*?)">(.*?)</a>} do |p, n|
      hash[n] = p
    end

    hash
  end

  def detail
    @detail unless @detail.nil?

    @detail = {}
    info.each_with_index do |(k, v), i|
      @detail[k] = v
      get(v).each do |kk, vv|
        @detail["#{k}.#{kk}"] = vv
      end
      $stderr.puts "#{i+1} / #{info.size}"
      sleep 1 if $local.nil?
      break
    end

    @detail
  end
end

if __FILE__ == $0
  puts TocParser.new(ARGV[0]).detail.to_json
end
