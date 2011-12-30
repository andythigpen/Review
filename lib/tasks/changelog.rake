
# modified from https://gist.github.com/802396
desc "Generates changelog"
task :changelog, :since_c, :until_c do |t,args|
  since_c = args[:since_c] || `git tag | head -1`.chomp
  until_c = args[:until_c]
  cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' \"#{since_c}\"..\"#{until_c}\"`

  entries = Hash.new
  changelog_content = String.new
  url = "http://github.com/andythigpen/Review/commit"

  cmd.split("\n").each do |entry|
    date, author, subject, hash = entry.chomp.split("::")
    day = date.split(" ").first
    entries[day] = Array.new unless entries[day]
    entries[day] << "#{subject} (<a href=\"#{url}/#{hash}\" target=\"_blank\">#{hash[0..6]}</a>)" unless subject =~ /Merge|Updates changelog/
  end

  puts "Writing out changelog from #{since_c}..#{until_c}"
  days = entries.keys.sort {|a,b| a <=> b }
  # generate clean output
  days.reverse.each do |day|
    puts "Adding entry for #{day}"
    formatted_day = `date --date="#{day}" "+%a %b %e, %Y"`.chomp
    changelog_content += "<h1>#{formatted_day}</h1>\n<ul class=\"changelog\">\n"
    entries[day].reverse.each do |entry| 
      changelog_content += "  <li>#{entry}</li>\n"
    end
    changelog_content += "</ul>\n\n"
  end

  original_file = "app/views/home/changelog.html.erb"
  new_file = original_file + ".new"
  File.open(new_file, "w") do |f|
    f.puts changelog_content
    File.foreach(original_file) do |line|
      f.puts line
    end
  end
  File.rename(new_file, original_file)
  puts "Don't forget to commit it!\n"
end
