'use strict';

// TODO: 1. Refactor tasks with named logic functions to avoid anonymous functions
// https://github.com/gulpjs/gulp/issues/1392#issuecomment-156789791
// 2. Declare input and output objects for better maintenance

const fs = require('fs'),
    gulp = require('gulp'),
    exist = require('@existdb/gulp-exist'),
    watch = require('gulp-watch'),
    less = require('gulp-less'),
    sourcemaps = require('gulp-sourcemaps'),
    path = require('path'),
    del = require('del'),
    LessAutoprefix = require('less-plugin-autoprefix'),
    autoprefixer = new LessAutoprefix({ browsers: ['last 2 versions'] });


// Deployment //

let localConnectionOptions = {};

if (fs.existsSync('./local.node-exist.json')) {
    localConnectionOptions = require('./local.node-exist.json');
    console.log('read from localConnectionOptions', localConnectionOptions)
}

let exClient = exist.createClient(localConnectionOptions);

/* create a file named 'local.node-exist.json' with the following content:
{
  "host": "localhost",
  "port": "8080",
  "path": "/exist/xmlrpc",
  "basic_auth": {
    "user": "admin",
    "pass": ""
  }
}
*/

let targetConfiguration = { target: '/db/apps/lgpn-ling/' }

gulp.task('clean', function() {
    return del([
        'build/**/*',
        'resources/css/style.css',
        'resources/fonts/*'
    ]);
});


// Scripts //

gulp.task('scripts:deploy', function () {
    return gulp.src('resources/scripts/*', {base: '.'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('scripts:watch', function () {
    gulp.watch('resources/scripts/**/*.js', gulp.series('scripts:deploy'))
});


// Styles //

gulp.task('styles:build', gulp.series('clean', function () {
    let compiler = less({
        paths: [
            path.join(__dirname, "resources/js/vendor/bootstrap/less"),
            path.join(__dirname, "resources/css/less")
        ],
        plugins: [
            autoprefixer
        ]
    })
    return gulp.src('resources/css/less/style.less')
    .pipe(sourcemaps.init({largeFile: true}))
    .pipe(compiler)
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('resources/css'))
}));
0
gulp.task('styles:deploy', gulp.series('styles:build', function () {
    return gulp.src('resources/css/*.css', {base: './'})
    .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('styles:watch', function () {
    gulp.watch('resources/css/less/**/*.less', gulp.series('styles:deploy'))
});


// Pages //

let pagesPath = '*.html';
gulp.task('pages:deploy', function () {
    return gulp.src(pagesPath, {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('pages:watch', function () {
    gulp.watch(pagesPath, gulp.series('pages:deploy'))
});

// Templates //

let templatesPath = 'templates/**/*.html';
gulp.task('templates:deploy', function () {
    return gulp.src(templatesPath, {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('templates:watch', function () {
    gulp.watch(templatesPath, gulp.series('templates:deploy'))
});

// Modules //

let modulesPath = 'modules/**/*';
gulp.task('modules:deploy', function () {
    return gulp.src(modulesPath, {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('modules:watch', function () {
    gulp.watch(modulesPath, gulp.series('modules:deploy'))
});

// Tests //

let testPath = 'tests/**/*';
gulp.task('deploy:test', function () {
    return gulp.src(testPath, {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('watch:test', function () {
    gulp.watch(testPath, gulp.series('deploy:test'))
});

// *************  Files in project root *************** //

let otherPath = '*{.xpr,.xqr,.xql,.xml,.xconf,.js}';

gulp.task('other:deploy', function () {
    return gulp.src(otherPath, {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
});

gulp.task('watch:other', function () {
    gulp.watch(otherPath, gulp.series('other:deploy'))
});


// General //

gulp.task('build', gulp.series('styles:build'));

gulp.task('deploy', gulp.series('build', function () {
    return gulp.src([
        'resources/**/*',
        pagesPath,
        modulesPath,
        templatesPath
    ], {base: './'})
    .pipe(exClient.newer(targetConfiguration))
    .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('watch', gulp.series('deploy', gulp.parallel('styles:watch', 'pages:watch', 'templates:watch', 'scripts:watch', 'modules:watch', 'watch:other')));

gulp.task('default', gulp.series('build'));
