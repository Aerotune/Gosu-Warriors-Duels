FRAME_EVENT_SYSTEMS = {}

Dir[File.join '.', 'app', 'frame_event_systems', '*.rb'].each do |file|
  require file
end