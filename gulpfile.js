'use strict';

var fs =                    require('fs'),
    gulp =                  require('gulp'),
    exist =                 require('gulp-exist'),
    newer =                 require('gulp-newer'),
    del =                   require('del'),
    less =                  require('gulp-less'),
    path =                  require('path'),
    sourcemaps =            require('gulp-sourcemaps'),
    LessAutoprefix =        require('less-plugin-autoprefix'),
    autoprefix =            new LessAutoprefix({ browsers: ['last 2 versions'] }),
    LessPluginCleanCSS =    require('less-plugin-clean-css'),
    cleanCSSPlugin =        new LessPluginCleanCSS({advanced: true}),


    input = {
        'html':             ['*.html', '*.xhtml'],
        'templates':         'templates/**/*.html',
        'css':               'resources/css/less/style.less',
        'scripts':           'resources/js/**/*',
        'vendor_scripts':    [
                                'bower_components/jquery/dist/jquery.min.js',
                                'bower_components/bootstrap/dist/js/bootstrap.min.js'
                             ],
        'xml':               'resources/xml/*.xml',
        'images':            'resources/img/**/*',
        'fonts':             'bower_components/bootstrap/fonts/**/*',
        'articles':          'data/articles/*.html',
        'i18n':              'data/i18n/*.xml'
    },
    output  = {
        'html':              '.',
        'templates':         'templates',
        'css':               'resources/css',
        'vendor_css':        'resources/css',
        'scripts':           'resources/js',
        'vendor_scripts':    'resources/js/vendor',
        'xml':               'resources/xml',
        'images':            'resources/img',
        'fonts':             'resources/fonts',
        'articles':          'data/articles',
        'i18n':              'data/i18n'
    }
    ;

// *************  existDB configuration *************** //

// var localConnectionOptions = {};
//
// if (fs.existsSync('./local.node-exist.json')) {
//     localConnectionOptions = require('./local.node-exist.json');
//     console.log('read from localConnectionOptions', localConnectionOptions)
// }
//
// var exClient = exist.createClient(localConnectionOptions);
//
// var targetConfiguration = {
//     target: '/db/apps/lgpn-ling/'
// };

exist.defineMimeTypes({
    'application/xml': ['odd']
});

var exClient = exist.createClient({
    host: 'localhost',
    port: '8080',
    path: '/exist/xmlrpc',
    basic_auth: { user: 'admin', pass: '' }
});

var targetConfiguration = {
    target: '/db/apps/lgpn-ling/',
    html5AsBinary: true
};

// ****************  Styles ****************** //

gulp.task('build:styles', function(){
    return gulp.src(input.css)
        .pipe(sourcemaps.init())
        .pipe(less({ plugins: [cleanCSSPlugin, autoprefix] }))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest(output.css))
});

gulp.task('deploy:styles', ['build:styles'], function () {
    console.log('deploying less and css files');
    return gulp.src('resources/css/**/*', {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('watch:styles', function () {
    console.log('watching less files');
    gulp.watch('resources/css/less/**/*.less', ['deploy:styles'])
});

// ****************  Fonts ****************** //

gulp.task('fonts:copy', function () {
    return gulp.src(input.fonts)
        .pipe(gulp.dest(output.fonts))
});

gulp.task('fonts:deploy', ['fonts:copy'], function () {
    return gulp.src(output.fonts, {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// ****************  Scripts ****************** //

gulp.task('vendor_scripts:copy', function () {
    return gulp.src(input.vendor_scripts)
        .pipe(gulp.dest(output.vendor_scripts));
});

gulp.task('deploy:scripts', ['vendor_scripts:copy'], function () {
    return gulp.src(input.scripts, {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch scripts
gulp.task('watch:scripts', function () {
    gulp.watch(input.scripts, ['deploy:scripts'])
});

// *************  Templates *************** //

// Deploy templates
gulp.task('deploy:templates', function () {
    return gulp.src(input.templates, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch templates
gulp.task('watch:templates', function () {
    gulp.watch(input.templates, ['deploy:templates'])
});

// *************  HTML Pages *************** //

// Deploy HTML pages
gulp.task('deploy:html', function () {
    return gulp.src(input.html, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch HTML pages
gulp.task('watch:html', function () {
    gulp.watch(input.html, ['deploy:html'])
});

// *************  XML Pages *************** //

gulp.task('deploy:xml', function () {
    return gulp.src(input.xml, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch xml files
gulp.task('watch:xml', function () {
   gulp.watch(input.xml, ['deploy:xml'])
});

// *************  Articles, i18n keys *************** //

gulp.task('deploy:articles', function () {
    return gulp.src(input.articles, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch articles
gulp.task('watch:articles', function () {
   gulp.watch(input.articles, ['deploy:articles'])
});

gulp.task('deploy:i18n', function () {
    return gulp.src(input.i18n, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Watch i18n
gulp.task('watch:i18n', function () {
   gulp.watch(input.i18n, ['deploy:i18n'])
});

// *************  General Tasks *************** //

var pathsToWatchAndDeploy = [
    'templates/**/*.html',
    'resources/**/*',
    'transform/*',
    '*.html',
    '*.xhtml',
    '*{.xpr,.xqr,.xql,.xml,.xconf}',
    'modules/**/*',
    '!build.*',
    'data/**/*'
];

// Watch and deploy all changed files
gulp.task('watch', ['watch:html', 'watch:styles', 'watch:scripts', 'watch:xml', 'watch:i18n', 'watch:articles']);

gulp.task('build', ['build:styles', 'fonts:copy', 'vendor_scripts:copy']);

// Deploy files to existDB
gulp.task('deploy', ['build'], function () {
    console.log('deploying files to local existdb');
    return gulp.src(pathsToWatchAndDeploy, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

// Default task (which is called by 'npm start' task)
gulp.task('default', ['build']);

