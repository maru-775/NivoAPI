require 'json'
require 'csv'

CSV.open("administrations_domaine_culture.csv", "w") do |csv|
  headers = ["Nom", "Email", "Code postal", "Site", "Mission"]
  csv << headers

  file_path = "assets/api-lannuaire-administration.json"
  json_data = File.read(file_path)
  data = JSON.parse(json_data)
  departments = ['16', '24', '33', '31', '32', '64', '65', '79', '86']
  key_words = ['culture', 'culturelle', 'culturel', 'art', 'communication', 'arts', 'bibliothèque', 'bibliothèques']
  data.each do |administration|
    if administration['adresse']
      address_array = JSON.parse(administration['adresse'])
      code_postal = address_array.find do |code|
        departments.any? { |departement| code['code_postal'].start_with?(departement) }
      end
      # puts code_postal if code_postal
      if administration['mission'] && code_postal
        email = administration['adresse_courriel']
        nom = administration['nom']
        site = administration['site_internet']
        mission_words = administration['mission'].downcase.split(/\W+/)
        matching_keywords_mission = mission_words.select { |word| key_words.include?(word) }
        if email
          email_words = email.downcase.split(/\W+/)
          matching_keywords_email = email_words.select { |word| key_words.include?(word) }
          if !matching_keywords_email.empty? || !matching_keywords_mission.empty?
            csv << [nom, email, code_postal['code_postal'], site, administration['mission']]
          end
        end
      end
    end
  end
end