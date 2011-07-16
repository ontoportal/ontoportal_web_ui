options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: import_ontologies.rb [options] file1 ..."

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  options[:quick] = false
  opts.on( '-q', '--quick', 'Perform the task quickly' ) do
    options[:quick] = true
  end

  options[:logfile] = nil
  opts.on( '-l', '--logfile FILE', 'Write log to FILE' ) do|file|
    options[:logfile] = file
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

begin
  optparse.parse!
  mandatory = [:from, :to]
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    puts "Missing options: #{missing.join(', ')}"                                                                                                          
    puts optparse                                                                                                                                          
    exit                                                                                                                                                   
  end                                                                                                                                                     
rescue OptionParser::InvalidOption, OptionParser::MissingArgument                                                                                                 
  puts $!.to_s                                                    
  puts optparse                                                   
  exit                                                            
end                                                               

optparse.parse!

puts "Being verbose" if options[:verbose]
puts "Being quick" if options[:quick]
puts "Logging to file #{options[:logfile]}" if options[:logfile]

ARGV.each do|f|
  puts "Resizing image #{f}..."
  sleep 0.5
end

