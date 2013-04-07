{spawn, exec} = require "child_process"

launch = (cmd, options=[]) ->
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  # app.on 'exit', (status) -> callback?() if status is 0

task 'build', 'Build src/ to build/.', ->
  launch "coffee", ["-c", "-o", "build/", "src/"]