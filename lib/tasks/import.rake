namespace :data do
    desc "Import recipes from recipes-en.json"
    task import: :environment do
      require "json"
      path = Rails.root.join("recipes-en.json")
      abort "File not found: #{path}" unless File.exist?(path)

      data = JSON.parse(File.read(path))
      puts "Importing #{data.size} recipes..."

      ActiveRecord::Base.logger.silence do
        Recipe.transaction do
          data.each_with_index do |r, i|
            
            recipe = Recipe.create!(
              title: r["title"],
              total_time: [r["cook_time"], r["prep_time"]].compact.sum,
              yields: r["yields"],
              image: r["image"],
            )

            (r["ingredients"] || r["ingredient_list"] || []).each do |raw|
              name = raw.to_s.downcase.strip
              next if name.empty?
              ing = Ingredient.find_or_create_by!(name: name)
              RecipeIngredient.create!(recipe:, ingredient: ing, raw_text: raw)
            end

            puts "Imported #{i + 1}/#{data.size}" if (i + 1) % 200 == 0
          end
        end
      end

      puts "Done."
    end
  end
