Gem::Specification.new do |s|
    s.name          = 'afstatsd'
    s.version       = '0.0.6'
    s.date          = '2013-07-23'
    s.summary       = "AppFirst StatsD Library"
    s.description   = "A StatsD library with AppFirst Extensions"
    s.authors       = ["Clark Bremer"]
    s.email         = 'clark@appfirst.com'
    s.license	    = 'APACHE'
    s.files         = ["lib/afstatsd.rb", 
                       "lib/afstatsd/statsd_aggregator.rb",
                       "lib/afstatsd/statsd_metrics.rb",
                       "example/example.rb"]
    s.extensions    = ['ext/mkrf_conf.rb']
    s.homepage      = 'http://appfirst.com'
end
