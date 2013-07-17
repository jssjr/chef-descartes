name             'descartes'
maintainer       'Scott Sanders'
maintainer_email 'scott@jssjr.com'
license          'All rights reserved'
description      'Installs/Configures descartes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apache2'
depends 'application_ruby'
depends 'database'
depends 'postgresql'
depends 'redis'
depends 'runit'
