
# dependencies
gulp = require 'gulp'

conf =
  isProduction: false
  isWatching: false

gulp.task 'default', ['watch']
gulp.task 'build', [
  'browserify'
  'sass'
  'html'
]
gulp.task 'watch', [
  'setWatch'
  'browserSync'
], ->
  gulp.watch 'src/sass/**', ['sass']
  gulp.watch 'src/index.html', ['html']
  # js watch handled by watchify

gulp.task 'clean', ->
  clean = require 'del'
  gulp.src([
      '.tmp'
      'dist'
    ],
      read: false
  ).pipe clean()

gulp.task 'reset', ->
  gulp.src([
    '.tmp'
    'dist'
    'node_modules'
    'src/bower_components'
    '.sass-cache'
  ],
    read: false
  ).pipe clean()

gulp.task 'html', ->
  gulp.src 'src/index.html'
    .pipe gulp.dest 'dist'
    .on 'error', handleErrors

gulp.task 'sass', ->
  sass = require 'gulp-sass'
  gulp.src './src/sass/style.scss'
    .pipe sass(
      sourceMap: 'sass'
      sourceComments: 'map')
    .pipe gulp.dest 'dist'

gulp.task 'setWatch', ->
  conf.isWatching = true

# scripts task
gulp.task 'browserify', ->
  source = require 'vinyl-source-stream'
  browserify = require 'browserify'
  b = browserify(
    extensions: ['.js','.coffee']
    entries: ['./src/js/app']
    debug: true
    cache: {}
    packageCache: {}
    fullPaths: true
  )
  bundle = ->
    logger.start()
    b.bundle()
      .on 'error', handleErrors
      .pipe source 'app.js'
      .pipe gulp.dest './dist/'
      .on 'end', logger.end
  
  # Rebundle with watchify on changes.
  if conf.isWatching
    watchify = require 'watchify'
    b = watchify b
    b.on 'update', bundle

  bundle()


gulp.task 'browserSync', ['build'], ->
  require 'browser-sync'
    .init ['dist/**'],
      server:
        baseDir: 'dist'
      host: 'localhost'

handleErrors = ->
  args = Array::slice.call(arguments)
  notify = require 'gulp-notify'
  # Send error to notification center with gulp-notify
  notify.onError(
    title: 'Compile Error'
    message: '<%= error.message %>'
  ).apply this, args
  # Keep gulp from hanging on this task
  @emit 'end'

gutil = require 'gulp-util'
prettyHrtime = require 'pretty-hrtime'
startTime = undefined
logger =
  start: ->
    startTime = process.hrtime()
    gutil.log 'Running', gutil.colors.green("'bundle'") + '...'
  end: ->
    taskTime = process.hrtime(startTime)
    prettyTime = prettyHrtime(taskTime)
    gutil.log 'Finished', gutil.colors.green("'bundle'"), 'in', gutil.colors.magenta(prettyTime)
