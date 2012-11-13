class aws {

	package { 'fog':
		ensure   => '1.7.0',
		provider => gem,
	}

}
