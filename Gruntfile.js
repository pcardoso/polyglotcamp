module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        clean: {
            templates_c: ['application/views/templates_c/*'],
            templates_cache: ['application/views/templates_cache/*']
        },

        compass: {                  // Task
            dist: {                   // Target
                options: {              // Target options
                    sassDir: 'sass',
                    cssDir: 'css',
                    imagesDir: 'images',
                    fontsDir: 'fonts',
                    outputStyle: 'expanded'
                }
            }
        },

        cssmin: {
            options: {
                keepSpecialComments: 0,
                report: 'gzip'
            },
            minify: {
                src: ['css/polyglot.css'],
                dest: 'css/polyglot.min.css',
            }
        },

        watch: {

          sass: {
            files: ['sass/**/*.scss'],
            tasks: ['compass','cssmin','clean'],
            options: {
              spawn: false,
            },
          },
        },

        imagemin: {
            all: {
              files: [{
                expand: true,
                cwd: 'images',
                src: ['**/*.{png,jpg,gif}'],
                dest: 'images'
              }]
            }
          }

    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-imagemin');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('css', ['compass','cssmin']);
    grunt.registerTask('default', ['watch']);

};
