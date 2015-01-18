module.exports = (grunt) ->

	grunt.template.addDelimiters('handlebars', '{{', '}}')

	grunt.initConfig(

		pkg: grunt.file.readJSON 'package.json'
		build_dir: 'build'
		js_dir: "<%= build_dir %>/assets/js"
		css_dir: "<%= build_dir %>/assets/css"

		#
		# COFFEESCRIPT COMPILATION

		coffee:
			main:
				options:
					join: true
					sourceMap: true
				files:
					"<%= js_dir %>/<%= pkg.name %>.js": ['src/coffee/*.coffee']

		#
		# SASS COMPILATION

		sass:
			options:
				style: 'compressed'
			main:
				files: ["<%= css_dir %>/<%= pkg.name %>.css": 'src/sass/main.scss']

		#
		# JS MINIFICATION

		uglify:
			main:
				options:
					wrap: "<%= pkg.name %>"
					banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
				files:
					"<%= js_dir %>/<%= pkg.name %>.min.js": "<%= js_dir %>/<%= pkg.name %>.js"
			templates:
				options:
					exposeAll: true
				files:
					"<%= js_dir %>/templates.min.js": "<%= js_dir %>/templates.js"

		#
		# SEMVER HELPER

		bump:
			options:
				pushTo: 'origin' 
				files: ['package.json', 'bower.json']
				commitFiles: ['package.json', 'bower.json']

		#
		# HTML + DEPENDENCIES

		copy:
			main:
				src: 'src/layout/index.tpl.html'
				dest: "<%= build_dir %>/index.html"
				options:
					process: (content) ->
						grunt.template.process(content, delimiters: 'handlebars')
			vendor:
				expand: true
				flatten: true
				src: [
					'node_modules/lodash/dist/lodash.min.js'
					'node_modules/eventify/dist/eventify.min.js'
					'bower_components/jquery/dist/jquery.min.js'
					'bower_components/jquery/dist/jquery.min.map'
					'bower_components/oauth-js/dist/oauth.min.js'
				]
				dest: "<%= build_dir %>/lib/"

		#
		# TEMPLATES
		
		jst:
			main:
				options:
					templateSettings:
						evaluate:    /\{\{(.+?)\}\}/g
						interpolate: /\{\{=(.+?)\}\}/g
						escape:      /\{\{-(.+?)\}\}/g
					processName: (filename) ->
						filename
							.slice(filename.indexOf('partials') + 9, filename.length)
							.replace('.tpl.html', '')

				files:
					"<%= js_dir %>/templates.js": ['src/layout/partials/**/*.tpl.html']

		#
		# LOCAL SERVER

		connect:
			main:
				options:
					hostname: 'localhost'
					port: 8000
					base:
						path: "<%= build_dir %>"
						options:
							index: 'index.html'

		#
		# WATCH

		watch:
			js:
				files: 'src/coffee/**/*.coffee'
				tasks: ['coffee']
			css:
				files: 'src/sass/**/*.scss'
				tasks: ['sass']
			templates:
				files: 'src/layout/**/*.html'
				tasks: ['copy:main', 'jst']

		#
		# CLEANUP

		clean: ["<%= build_dir %>"]

	)

	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-contrib-jst'
	grunt.loadNpmTasks 'grunt-bump'

	grunt.registerTask('default', ['clean', 'copy:main', 'copy:vendor', 'jst', 'coffee', 'sass'])
	grunt.registerTask('start', ['default', 'connect', 'watch'])
	grunt.registerTask('deploy', ['default', 'uglify'])

	null
