require 'find'

regex = /\..*[mch]$/
count = 0

Find.find("src") do |path|
  if FileTest.directory?(path)
    next
  else
    if regex.match(path)
      print "#{path}\n"
      # count lines
      lc = `wc -l #{path}`
      lc = /(\w+)\d*\w/.match(lc).captures[0]
      count = count + lc.to_i
    end
  end
end

print count
