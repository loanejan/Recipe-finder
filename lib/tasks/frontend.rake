# lib/tasks/frontend.rake
namespace :frontend do
    desc "Build the React frontend with Vite and copy the build output into Rails' public/ folder"
  
    task :build do
      rails_root   = Rails.root
      frontend_dir = rails_root.join("frontend")
      dist_dir     = frontend_dir.join("dist")
      public_dir   = rails_root.join("public")
  
      puts "📦 [frontend:build] Starting frontend build..."
  
      # 1. Vérifier que le dossier frontend existe
      unless Dir.exist?(frontend_dir)
        abort "❌ [frontend:build] Couldn't find #{frontend_dir}. Are you running this from the Rails project root?"
      end
  
      # 2. Installer les deps Node si node_modules est absent (pratique en déploiement)
      node_modules_dir = frontend_dir.join("node_modules")
      unless Dir.exist?(node_modules_dir)
        puts "⬇️  [frontend:build] node_modules missing. Running `npm install`..."
        Dir.chdir(frontend_dir) do
          system("npm install") or abort "❌ [frontend:build] npm install failed"
        end
      end
  
      # 3. Construire le bundle front avec Vite
      puts "🏗  [frontend:build] Running `npm run build`..."
      Dir.chdir(frontend_dir) do
        system("npm run build") or abort "❌ [frontend:build] npm run build failed"
      end
  
      unless Dir.exist?(dist_dir)
        abort "❌ [frontend:build] Build ok but no dist/ folder found at #{dist_dir}"
      end
  
      # 4. Nettoyer les anciens assets statiques dans public/
      #    On ne veut pas accumuler des vieux bundles.
      puts "🧹 [frontend:build] Cleaning old static files from public/..."
      # On enlève seulement les assets générés, pas les trucs Rails (genre favicon si tu en mets un)
      Dir.glob(public_dir.join("assets")).each { |path| FileUtils.rm_rf(path) }
      Dir.glob(public_dir.join("*.js")).each   { |path| FileUtils.rm_f(path) }
      Dir.glob(public_dir.join("*.css")).each  { |path| FileUtils.rm_f(path) }
      Dir.glob(public_dir.join("*.map")).each  { |path| FileUtils.rm_f(path) }
      Dir.glob(public_dir.join("index.html")).each { |path| FileUtils.rm_f(path) }
  
      # 5. Copier le nouveau build dist/* -> public/
      puts "📤 [frontend:build] Copying new build to public/..."
      FileUtils.cp_r("#{dist_dir}/.", public_dir)
  
      puts "✅ [frontend:build] Frontend build complete."
      puts "   Rails will now serve the latest React app from /public"
      puts "   You can run `bin/rails s` and open http://localhost:3000"
    end
  end
  