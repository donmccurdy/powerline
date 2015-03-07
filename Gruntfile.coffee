_ = require 'lodash'
path = require 'path'

module.exports = (grunt) ->

	grunt.template.addDelimiters 'handlebars', '{{', '}}'

	vendor_scripts = [
		'node_modules/lodash/dist/lodash.min.js'
		'node_modules/eventify/dist/eventify.min.js'
		'bower_components/jquery/dist/jquery.min.js'
		'bower_components/hello/dist/hello.all.min.js'
		'bower_components/mousetrap/mousetrap.min.js'
		'bower_components/jquery-sortable/source/js/jquery-sortable-min.js'
		'bower_components/asg.js/dist/asg.min.js'

		# DEV ONLY (todo)
		'bower_components/memory-stats/memory-stats.js'
	]

	grunt.initConfig(

		pkg: grunt.file.readJSON 'package.json'
		build_dir: 'build'
		js_dir: "<%= build_dir %>/assets/js"
		css_dir: "<%= build_dir %>/assets/css"

		#
		# SCRIPTS (there's got to be a way around this...)

		vendor_scripts: _.map vendor_scripts, path.basename

		dev_scripts: [
			'EventEmitter'
			
			'Bootstrap'
			'Cache'
			'Command'
			'CommandAggregator'
			'CommandQueue'
			'Keymap'
			'List'
			'ListCollection'
			'ListForm'
			'Selection'
			'Toolbar'
			'TwitterService'
			'UserStream'
			'Util'

			'main'
		]

		#
		# ENVIRONMENT

		env:
			dev:
				src: ['.env']
				NODE_ENV: 'DEVELOPMENT'
			prod:
				NODE_ENV: 'PRODUCTION'

		#
		# COFFEESCRIPT COMPILATION

		coffee:
			dist:
				options:
					join: true
					sourceMap: true
				files:
					"<%= js_dir %>/<%= pkg.name %>.js": ['src/coffee/*.coffee']
			dev:
				expand: true
				flatten: true
				options:
					bare: true
					sourceMap: true
				src: "<%= js_dir %>/.tmp/*.coffee"
				dest: "<%= js_dir %>/.tmp/"
				ext: '.js'

		#
		# SASS COMPILATION

		sass:
			options:
				style: 'compressed'
			main:
				files:
					"<%= css_dir %>/<%= pkg.name %>.css": 'src/sass/main.scss'
					"<%= css_dir %>/autocomplete.css": 'src/sass/autocomplete.scss'

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
						grunt.template.process content, delimiters: 'handlebars'
			dev:
				expand: true
				flatten: true
				src: 'src/coffee/*.coffee'
				dest: "<%= js_dir %>/.tmp/"
			vendor:
				expand: true
				flatten: true
				src: vendor_scripts.concat [
					'bower_components/jquery/dist/jquery.min.map'
					'bower_components/jquery/dist/jquery.js'
					'bower_components/asg.js/dist/asg.min.css'
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
				tasks: ['copy:dev', 'coffee:dev']
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
	grunt.loadNpmTasks 'grunt-env'

	grunt.registerTask 'common', ['clean', 'copy:main', 'copy:vendor', 'jst', 'sass']
	grunt.registerTask 'dev', ['env:dev', 'common', 'copy:dev', 'coffee:dev', 'connect', 'watch']
	grunt.registerTask 'prod', ['env:prod', 'common', 'coffee:dist', 'uglify']
	grunt.registerTask 'default', ['prod']

	null
