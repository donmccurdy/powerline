class ListForm extends EventEmitter

	DEFAULT_METADATA:
		id: 0
		name: ''
		description: ''
		mode: 'private'

	constructor: (@twitter, @metadata = @DEFAULT_METADATA) ->
		@el = $ JST['modal'](content: JST['list-form'](@metadata))
		@el.modal
			backdrop: true
			keyboard: true
			show: true
		@el.on 'click', '.btn-primary', => @save()
		@el.on 'hidden.bs.modal', => @close()

	close: () ->
		@el.modal 'hide'
		_.delay ( =>
				@el.remove()
				@trigger 'destroy'
			),
			500

	save: () ->
		@metadata.name = @el.find('.name').val()
		@metadata.description = @el.find('.description').val()
		@metadata.mode = @el.find('input[name=mode]:checked').val()
		if @validate()
			@twitter.upsertList @metadata
				.done (list) =>
					@trigger 'save', list
					@close()
				.fail => @el.addClass 'exception'
		else
			$.Deferred().reject()

	validate: () ->
		unless @metadata.name
			@el.find('.name-group').addClass 'has-error'
			false
		else
			true
