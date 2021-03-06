var gulp = require('gulp'),
    sass = require("gulp-sass"),
    coffee = require("gulp-coffee"),
    sourcemaps = require("gulp-sourcemaps"),
    minifycss = require("gulp-minify-css"),
    uglify = require("gulp-uglify"),
    rename = require("gulp-rename"),
    connect = require('gulp-connect');

// task
gulp.task('coffee', function() {
    gulp.src('src/jquery-select-areas.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('dist'))
    .pipe(uglify())
    .pipe(rename('jquery-select-areas.min.js'))
    .pipe(gulp.dest('dist'))
});

gulp.task('sass', function() {
    gulp.src('src/jquery-select-areas.scss')
    .pipe(sass())
    .pipe(gulp.dest('dist'))
    .pipe(minifycss())
    .pipe(rename('jquery-select-areas.min.css'))
    .pipe(gulp.dest('dist'))
});

gulp.task('watch', function () {
        gulp.watch('src/*.coffee', ['coffee'])
        gulp.watch('src/*.scss', ['sass'])
});

gulp.task('serve', function () {
    connect.server({
        root: '',
        port: 13000,
        livereload: true
    });

    gulp.watch(['*.html', 'dist/*.*'], function() {
        connect.reload()
    });
});

gulp.task('build', ['coffee', 'sass']);

gulp.task('default', ['build', 'watch', 'serve']);
