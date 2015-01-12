module.exports = (grunt) ->

	# Project configuration.
	grunt.initConfig(

		pkg: grunt.file.readJSON 'package.json'

		coffee:
			app:
				options:
					join: true
					sourceMap: true
				files:
					'build/<%= pkg.name %>.js': ['src/coffee/*.coffee']

		sass:
			options:
				style: 'compressed'
			dist:
				files: ['build/<%= pkg.name %>.css': 'src/sass/main.scss']

		uglify:
			options:
				banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
			build:
				src: 'build/<%= pkg.name %>.js'
				dest: 'build/<%= pkg.name %>.min.js'

		bump:
			options:
				files: [
					"package.json", 
					"bower.json"
				],
				commit: false,
				commitFiles: [
				  "package.json", 
				  "bower.json"
				],
				push: false,
				pushTo: 'origin' 

		clean: ['build']
	)

	grunt.loadNpmTasks 'grunt-contrib-requirejs'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-bump'

	# Default task(s).
	grunt.registerTask('default', ['clean', 'coffee', 'uglify', 'sass'])
	null