#!/usr/bin/env ruby

buildNumber = File.new("buildnumber", "r").gets

plistFile = "iKnowAndManage.plist"
propKey = "CFBundleShortVersionString"

svs = `./PlistUtil '#{plistFile}' get #{propKey}` 
svs = "%s-%s" % [svs.split("-")[0], buildNumber]

`./PlistUtil '#{plistFile}' put #{propKey} #{svs}`
