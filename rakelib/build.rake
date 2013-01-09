require 'functions'

file "#{BUILD_DIR}/mruby_exe.js" => ["#{BUILD_DIR}/main.o", "#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{BUILD_DIR}/post.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, ['main'])

  sh "#{LD} #{BUILD_DIR}/main.o #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby_exe.js --js-library #{BUILD_DIR}/gem_library.js --post-js #{BUILD_DIR}/post.js #{func_arg}"
end

file "#{BUILD_DIR}/mruby.js" => ["#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{BUILD_DIR}/post.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, [])

  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby.js --js-library #{BUILD_DIR}/gem_library.js --post-js #{BUILD_DIR}/post.js #{func_arg}"
end

file "#{BUILD_DIR}/gem_library.js" => "#{LIBMRUBY_FILE}" do |t|
  sh "ruby scripts/gen_gems_config.rb #{MRUBY_BUILD_CONFIG} #{BUILD_DIR}/gem_library.js #{BUILD_DIR}/functions"
end

file "#{BUILD_DIR}/post.js" => :post_js

# This needs to run each time since changing loading mode
# does not trigger any file changes.
task :post_js do |t|
  sh "ruby scripts/gen_post.rb #{LOADING_MODE} #{BUILD_DIR}/post.js"
end