# lib/tasks/frontend.rake
namespace :frontend do
  desc "Build the React frontend with Vite and copy the build output into Rails' public/ folder"
  task :build do
    require "fileutils"

    rails_root   = Rails.root
    frontend_dir = rails_root.join("frontend")
    dist_dir     = frontend_dir.join("dist")
    public_dir   = rails_root.join("public")

    puts "📦 [frontend:build] Starting frontend build..."

    # 1. Vérifier que le dossier frontend existe
    unless Dir.exist?(frontend_dir)
      abort "❌ [frontend:build] Couldn't find #{frontend_dir}. Are you running this from the Rails project root?"
    end

    # 2. Déterminer le gestionnaire de packages JS (yarn ou npm)
    pkg_manager =
      if File.exist?(frontend_dir.join("yarn.lock"))
        "yarn"
      else
        "npm"
      end

    install_cmd =
      if pkg_manager == "yarn"
        "yarn install --frozen-lockfile"
      else
        "npm install"
      end

    build_cmd =
      if pkg_manager == "yarn"
        "yarn build"
      else
        "npm run build"
      end

    # 3. Installer les deps Node si node_modules est absent ou vide
    node_modules_dir = frontend_dir.join("node_modules")
    if !Dir.exist?(node_modules_dir) || Dir.children(node_modules_dir).empty?
      puts "⬇️  [frontend:build] installing frontend deps (#{pkg_manager})..."
      Dir.chdir(frontend_dir) do
        system(install_cmd) or abort "❌ [frontend:build] #{install_cmd} failed"
      end
    else
      puts "⬇️  [frontend:build] skipping install (node_modules present)"
    end

    # 4. Construire le frontend (Vite / React build)
    puts "🏗  [frontend:build] building frontend (#{build_cmd})..."
    Dir.chdir(frontend_dir) do
      system(build_cmd) or abort "❌ [frontend:build] #{build_cmd} failed"
    end

    unless Dir.exist?(dist_dir)
      abort "❌ [frontend:build] Build finished but dist/ folder not found at #{dist_dir}"
    end

    # 5. Nettoyer les anciens assets statiques dans public/
    puts "🧹 [frontend:build] cleaning old static files from public/..."

    # On supprime ce qui venait du build précédent,
    # sans toucher aux pages Rails genre 404.html, favicon, etc.
    to_delete_patterns = [
      public_dir.join("assets").to_s,
      public_dir.join("*.js").to_s,
      public_dir.join("*.css").to_s,
      public_dir.join("*.map").to_s,
      public_dir.join("index.html").to_s
    ]

    to_delete_patterns.each do |pattern|
      Dir.glob(pattern).each do |path|
        FileUtils.rm_rf(path)
      end
    end

    # 6. Copier le nouveau build dans public/
    puts "📤 [frontend:build] copying new build to public/..."
    FileUtils.cp_r("#{dist_dir}/.", public_dir)

    puts "✅ [frontend:build] Frontend build complete."
    puts "   -> Rails will now serve the latest React app from /public"
  end
end

namespace :app do
  desc "Prepare production DB locally (migrate and optional seed)"
  task :prepare_db => :environment do
    puts "🗄  [app:prepare_db] migrating production DB (SQLite)..."
    system("RAILS_ENV=production bin/rails db:migrate") or abort "❌ migration failed"

    # Décommenter si tu veux préremplir la base avec des données (ex: importer les recettes)
    # puts '🌱  [app:prepare_db] seeding production DB...'
    # system("RAILS_ENV=production bin/rails db:seed") or abort "❌ seed failed"

    puts "✅ [app:prepare_db] DB is migrated for production."
  end

  desc "Build frontend, prepare DB, and deploy to Fly.io in one shot"
  task :deploy do
    # 1. Build du frontend (copie dans public/)
    Rake::Task["frontend:build"].invoke

    # 2. Migration (et seed éventuel) en prod pour générer/mettre à jour db/production.sqlite3
    Rake::Task["app:prepare_db"].invoke

    # 3. Déploiement Fly.io
    puts "🚀 [app:deploy] deploying to Fly.io..."
    system("flyctl deploy") or abort "❌ flyctl deploy failed"

    puts "✨ [app:deploy] Done!"
    puts "    Your app should now be live on Fly.io."
  end
end
