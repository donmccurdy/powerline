class ListForm extends EventEmitter

	DEFAULT_METADATA:
		id: 0
		name: ''
		description: ''
		mode: 'private'

	constructor: (@twitter, @metadata = @DEFAULT_METADATA) ->
		@el = $ JST['list-form'](@metadata)
		@el.modal
			backdrop: true
			keyboard: true
			show: true
		@el.on 'click', '.btn-primary', => @save()
		@el.on 'hidden.bs.modal', => @close()

	close: () ->
		@el.remove()
		@trigger 'destroy'

	save: () ->
		@metadata.name = @el.find('.name').val()
		@metadata.description = @el.find('.description').val()
		@metadata.mode = @el.find('input[name=mode]:checked').val()

		@twitter.upsertList @metadata
			.done (list) =>
				@trigger 'save', list
				@close()
			.fail => @el.addClass 'exception'
