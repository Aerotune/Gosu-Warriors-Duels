CHARACTER_STATS_PATHS = File.join('resources', 'character_stats', '*.json')

CHARACTER_STATS = Hash.new { |h,k| h[k] = {} }

module CharacterStatsLoader
  def self.load_all!
    Dir[CHARACTER_STATS_PATHS].each do |path|
      CharacterStatsLoader.load_character_stats! path
    end
  end
  
  def self.load_character_stats! path
    entity_class = File.basename path, '.json'
    data = JSON.parse File.read(path)
    
    CHARACTER_STATS[entity_class] = data
  end
end
