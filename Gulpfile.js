var gulp = require('gulp'),
    sass = require("gulp-sass"),
    coffee = require("gulp-coffee"),
    connect = require('gulp-connect');

// task
gulp.task('coffee', function() {
    gulp.src('src/jquery-select-areas.coffee')
    .pipe(coffee())
    .pipe(gulp.dest('dist'))
});

gulp.task('sass', function() {
    gulp.src('src/jquery-select-areas.scss')
    .pipe(sass())
    .pipe(gulp.dest('dist'))
});

gulp.task('watch', function () {
        gulp.watch('src/*.coffee', ['coffee'])
        gulp.watch('src/*.scss', ['sass'])
});

gulp.task('serve', function () {
    connect.server({
        root: '',
        port: 8080,
        livereload: true
    });

    gulp.watch(['*.html', 'dist/*.*'], function() {
        connect.reload()
    });
});


gulp.task('build', ['coffee', 'sass']);

gulp.task('default', ['watch', 'serve']);
