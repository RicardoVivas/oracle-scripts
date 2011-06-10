    case $operatingsystem {
      centos: { $apache = "httpd" }
      # Note that these matches are case-insensitive.
      redhat: { $apache = "httpd" }
      debian: { $apache = "apache2" }
      ubuntu: { $apache = "apache2" }
      default: { fail("Unrecognized operating system for webserver") }
      # "fail" is a function. We'll get to those later.
    }
    
    package {'apache':
      name   => $apache,
      ensure => latest,
    }
    
     notify {"The apache is $apache":}