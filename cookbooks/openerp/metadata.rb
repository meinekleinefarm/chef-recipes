name             'openerp'
maintainer       "Christoph Buente"
maintainer_email "cb@meinekleinefarm.org"
license          'All rights reserved'
description      'Installs/Configures openerp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'database'
depends 'firewall'
