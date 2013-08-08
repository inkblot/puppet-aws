class aws {

	package { 'fog':
		ensure   => latest,
		provider => gem,
	}

}
