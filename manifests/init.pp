# ex: syntax=puppet si ts=4 sw=4 et
class aws {

	package { 'fog':
		ensure   => latest,
		provider => gem,
	}

	package { 's3cmd':
		ensure   => latest,
	}

}
