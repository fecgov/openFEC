'use strict';

var gulp = require('gulp');
var es = require('event-stream');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var less = require('gulp-less');
var handlebars = require('gulp-handlebars');
var wrap = require('gulp-wrap');
var declare = require('gulp-declare');
var order = require('gulp-order');

// process handlebars templates
function templates() {
  return gulp
    .src(['./swagger-ui/hbs/**/*'])
    .pipe(handlebars({
      // use required version of handlebars
      // instead of gulp-handlebars default
      handlebars: require('handlebars')
    }))
    .pipe(wrap('Handlebars.template(<%= contents %>)'))
    .pipe(declare({
      namespace: 'Handlebars.templates',
      noRedeclare: true, // Avoid duplicate declarations
    }));
}

// build swagger-ui + custom javascript
gulp.task('build-js', function() {
  return es.merge(
      gulp.src([
        './swagger-ui/js/**/*.js'
      ]),
      templates()
    )
    .pipe(order(['scripts.js', 'templates.js']))
    .pipe(concat('swagger-ui.js'))
    .pipe(wrap('(function(){<%= contents %>}).call(this);'))
    .pipe(gulp.dest('./static/swagger-ui/js'))
    .pipe(uglify())
    .pipe(rename({extname: '.min.js'}))
    .pipe(gulp.dest('./static/swagger-ui/js'));
});

// compile less files
gulp.task('build-less', function() {
  return gulp
    .src([
      './swagger-ui/less/screen.less',
      './swagger-ui/less/print.less',
      './swagger-ui/less/reset.less'
    ])
    .pipe(less())
    .pipe(gulp.dest('./static/swagger-ui/css'));
});

// running gulp will build both js and less files
gulp.task('default', ['build-js', 'build-less']);
