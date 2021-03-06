require 'puppet/provider/parsedfile'

Puppet::Type.type(:tcif_instance_conf).provide(
  :tcif_instance_conf,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => '/usr/local/tomcat_instances/_TooDB/conf/instance.env',
  :filetype => :flat
) do
  desc "Set key/values in instance.env."

  text_line :comment, :match => /^\s*#/
  text_line :blank, :match => /^\s*$/

  record_line :parsed, :fields => %w{name}

#  record_line :parsed,
#    :fields   => %w{name value comment},
#    :optional => %w{comment},
#    :match    => /^\s*([\w\.]+)\s*=?\s*(.*?)(?:\s*#\s*(.*))?\s*$/,
#    :to_line  => proc { |h|
#
#      # simple string and numeric values don't need to be enclosed in quotes
#      if h[:value].is_a?(Fixnum)
#        val = h[:value].to_s
#      else
#        val = h[:value]
#      end
#      dontneedquote = val.match(/^(\w+)$/)
#      dontneedequal = h[:name].match(/^(include|include_if_exists)$/i)
#
#      str =  h[:name].downcase # normalize case
#      str += dontneedequal ? ' ' : ' = '
#      str += "'" unless dontneedquote && !dontneedequal
#      str += val
#      str += "'" unless dontneedquote && !dontneedequal
#      str += " # #{h[:comment]}" unless (h[:comment].nil? or h[:comment] == :absent)
#      str
#    },
#    :post_parse => proc { |h|
#      h[:name].downcase! # normalize case
#      h[:value].gsub!(/(^'|'$)/, '') # strip out quotes
#    }

end