# A class to install WP-CLI.
class wp::cli (
	$ensure       = 'installed',
	$install_path = '/usr/local/src/wp-cli',
	$version      = 'dev-master',

) {
	include wp

	if 'installed' == $ensure or 'present' == $ensure {
		# Create the install path
		file { [ $install_path, "${install_path}/bin" ]:
			ensure => directory,
		}

		# Clone the Git repo
		exec { 'wp-cli download':
			command => "/usr/bin/curl -o ${install_path}/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
			require => [ Package[ 'curl' ], File[ $install_path ] ],
			creates => "${install_path}/bin/wp"
		}

		# Ensure we can run wp-cli
		file { "${install_path}/bin/wp":
			ensure  => 'present',
			mode    => 'a+x',
			require => Exec[ 'wp-cli download' ]
		}

		# Symlink it across
		file { "${wp::params::bin_path}/wp":
			ensure  => link,
			target  => "${install_path}/bin/wp",
			require => File[ "${install_path}/bin/wp" ],
		}
	}
	elsif 'absent' == $ensure {
		file { "${wp::params::bin_path}/wp":
			ensure => absent,
		}
		file { '/usr/local/src/wp-cli':
			ensure => absent,
		}
	}

	if ! defined( Package[ $::wp::php_package ] ) {
		package { $::wp::php_package:
			ensure => installed,
		}
	}

	if ! defined(Package['curl']) {
		package { 'curl':
			ensure => installed,
		}
	}

	if ! defined(Package['git']) {
		package { 'git':
			ensure => installed,
		}
	}
}
