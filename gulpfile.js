var gulp = require("gulp");
var sass = require("gulp-sass");
var concat = require("gulp-concat");
var merge = require("merge-stream");
var uglify = require("gulp-uglify");
var through = require("through2");

var options = {
  sass: {
    outputStyle: "compressed",
    includePaths: [__dirname + "/vendor/assets/bootstrap/scss"]
  },
  uglify: {
    mangle: false,
  },
};


// STYLESHEETS

gulp.task("sass", function () {
  return gulp
    .src("app/assets/stylesheets/*.scss")
    .pipe(sass(options.sass)
    .on("error", sass.logError))
    .pipe(gulp.dest("public/stylesheets"));
});

gulp.task("sass:watch", function () {
  return gulp.watch("app/assets/stylesheets/**/*.scss", ["sass"]);
});


// JAVASCRIPTS

function wrapLanguage() {
  var re = /\/([^\/]+)\.js$/;

  return through.obj(function (file, encoding, callback) {
    var name = file.path.match(re)[1];
    var contents = file.contents.toString();
    file.contents = new Buffer("hljs.registerLanguage('" + name + "', " + contents + ");");
    callback(null, file);
  });
}

gulp.task("hljs", function () {
  var hljs = gulp
    .src("vendor/assets/highlight/src/highlight.js");

  var languages = gulp.src([
      "vendor/assets/highlight/src/languages/crystal.js",
      "vendor/assets/highlight/src/languages/cpp.js",
      "vendor/assets/highlight/src/languages/json.js",
      "vendor/assets/highlight/src/languages/html.js",
      "vendor/assets/highlight/src/languages/javascript.js",
      "vendor/assets/highlight/src/languages/coffeescript.js",
      "vendor/assets/highlight/src/languages/css.js",
      "vendor/assets/highlight/src/languages/scss.js",
      "vendor/assets/highlight/src/languages/yaml.js",
    ])
    .pipe(wrapLanguage());

  return merge(hljs, languages)
    .pipe(concat("highlight.js"))
    .on("error", console.error.bind(console))
    .pipe(gulp.dest("vendor/assets/highlight"));
});

gulp.task("hljs:languages", function () {
  return gulp
    .src("vendor/assets/highlight/src/languages/*.js")
    .pipe(wrapLanguage())
    .pipe(uglify(options.uglify))
    .on("error", console.error.bind(console))
    .pipe(gulp.dest("public/javascripts/highlight"));
});

gulp.task("js", ["hljs"], function () {
  return gulp
    .src([
      "vendor/assets/vanilla-ujs/vanilla-ujs.js",
      "vendor/assets/highlight/highlight.js",
    ])
    .pipe(concat("application.js"))
    .pipe(uglify(options.uglify))
    .on("error", console.error.bind(console))
    .pipe(gulp.dest("public/javascripts"));
});


// TASKS

gulp.task("default", ["sass", "hljs:languages", "js"]);
gulp.task("watch", ["sass:watch"]);
