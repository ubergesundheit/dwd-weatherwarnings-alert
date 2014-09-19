#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'time'
require 'yaml'
require 'blather/client'

@config = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))

def get_warning(areadesc: @config['areadesc'], time_format: "%H:%M", date_format: "%-e.%-m.%Y", num_retrys: 5, wait_time_seconds: 10)
  wanted_attributes = %w(HEADLINE DESCRIPTION EXPIRES ONSET IDENTIFIER)
  time_format_full = "#{time_format} #{date_format}"
  url = "http://maps.dwd.de/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&typename=dwd:BASISWARNUNGEN"
  url << "&bbox=#{@config['bbox']}" unless @config['bbox'] == nil

  begin
    tries ||= num_retrys
    doc = Nokogiri::XML(open(url))
    area = doc.xpath("//wfs:member/dwd:BASISWARNUNGEN/dwd:AREADESC[text()='#{areadesc}']/..")
  rescue *[Nokogiri::XML::XPath::SyntaxError, Errno::ENOENT] => e
    sleep wait_time_seconds
    retry unless (tries -= 1).zero?
    "error after #{num_retrys} retries: #{e}"
  end

  unless area == nil or area.empty?
    warning = {}
    area.children.each do |attr|
      warning[attr.name.downcase.to_sym] = attr.text if wanted_attributes.include? attr.name
    end
    warning[:expires] = Time.parse warning[:expires]
    warning[:onset] = Time.parse warning[:onset]
    binding.pry

    unless compare_saved_warning warning
      "Von #{warning[:onset].localtime.strftime time_format_full} bis #{warning[:expires].localtime.strftime time_format_full} #{warning[:headline]}: #{warning[:description]}"
    end
  end
end

def compare_saved_warning(warning)
  persistence_items = %w{identifier onset expires}
  filename = 'saved_warning'
  begin
    File.open( File.join(File.dirname(File.expand_path(__FILE__)), filename), 'r+') do |file|
      saved_warning = {}

      file.read.split(',').zip(persistence_items).each do |saved_item, warning_key|
        key = warning_key.to_sym
        saved_warning[key] = saved_item
        saved_warning[key] = Time.parse saved_warning[key] unless warning_key == 'identifier'
      end
      # the file is empty.. write a new one.
      raise Errno::ENOENT if saved_warning == {}
      # wipe the saved warning if expires is in the past
      if saved_warning[:expires] < Time.now
        file.truncate 0
      end

      # are the saved warning identifier and current identifier the same?
      # is the onset changed?
      if warning[:identifier] != saved_warning[:identifier] or warning[:onset] != saved_warning[:onset]
        raise Errno::ENOENT # also return false
      end

      # return value of the method
      true
    end
  rescue Errno::ENOENT
    File.open( File.join(File.dirname(File.expand_path(__FILE__)), filename), 'w') do |file|
      file.write(persistence_items.map { |item| warning[item.to_sym] }.join(','))
    end
    false
  end
end


result = get_warning
setup @config['jid'], @config['password'], 'talk.google.com'

 when_ready do
  if result != nil
    @config['send_to'].each do |addr|
      say addr, result
    end
  end
  sleep 10
  shutdown
end

