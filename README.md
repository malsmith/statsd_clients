![Appfirst](http://www.appfirst.com/img/appfirst-logo.png)
Statsd Java Clients by [AppFirst](http://www.appfirst.com)
====================================

For Statsd, here's a definition I like from [Native StatsD integration with Gauges and Percentiles](http://blog.librato.com/2012/05/new-statsd-integration-with-gauges-and.html) by Mike Heffner from Librato.

> StatsD is a simple network daemon that continuously receives metrics pushed over UDP and periodically sends aggregate metrics to upstream services like Graphite and Librato Metrics. Because it uses UDP, clients (for example, web applications) can ship metrics to it very fast with little to no overhead. This means that a user can capture multiple metrics for every request to a web application, even at a rate of thousands of requests per second. Request-level metrics are aggregated over a flush interval (default 10 seconds) and pushed to an upstream metrics service.

There are currently 3 types of stats: [Counting](#couting), [Timing](#timing) and [Gauge](#gauge).) Etsy has defined the [concepts](https://github.com/etsy/statsd#concepts). 

## Use Statsd Client
-------------------

To use Statsd client, it's ridiculously easy and straightforward:

	StatsdClient client = new StatsdClient();
	client.increment("some_bucket");
	
By doing this, you sent a message look like this:

	some_bucket:1|c
	
That's it! Use it anywhere in your code to get statistical data over time, the server will do everything for you. Currently there are several implementation available in the wild, such as the original [etsy/statsd](https://github.com/etsy/statsd) implementation and [AppFirst Collector][collector]'s seamless integration. Here is [a list of them](http://joemiller.me/2011/09/21/list-of-statsd-server-implementations/).

There are totally three modules for python client. The main functionality are all included in `client.py`.  
To use statsd client with UDP, you also have to setup `local_settings.py` if your server is not on localhost or not using default port.  
To use it with AppFirst Collector, you will need the `AFTransport` from `afclient.py`, please see below.

###AppFirst Extension:

By default, Statsd client in client.py uses UDP [Transport](#about-transport) to sent messages. To use with AppFirst Collector (please [install the collector][collector] before you do), switch to the AppFirst [Transport](#about-transport) before usage **FOR ONE TIME ONLY** or simply import it from afclient.py (Statsd client use `AFTransport` by default in this module):

	import com.appfirst.statsd.StatsdClient;	
	import com.appfirst.statsd.AFTransport;
	
	public class SomeClass{

		public static void main(){

			Transport transport = new AFTransport();
			StatsdClient client = new StatsdClient(transport);

			client.increment("bucket");
		}
	}

We also accept message as extension. On the graph the message will be display for each tick.
<!--We need a example pic to demostrate here.-->
The format will be position-invariant:

	bucket: field0 | field1 | field2                 | field3
	bucket: value  | unit   | sampele_rate/timestamp | message

e.g. a counter message and a gauge message look like the following:

	bucket:2|c|0.1|some_message
	bucket:333|g|1344570108|some_message

when message is there, we always keep field2 even if it's blank:

	bucket:10|ms||some_message

Please see below for detail usage.
	
## Counting
-------------------
**increment(buckets, sample_rate=1, message=None)**
	
To increment one or more stats counters, message is available with **[AppFirst Extended Format](#appfirst-extension)** only.
	    	
Here's an example (the second example are using [sample rate](#sample-rate)):

	StatsdClient client = new StatsdClient(new AFTransport());
	client.increment("some.int", "some.int2");
	
'c' is the unit for counter. This will send messages:

	some.int:1|c
	some.int2:1|c

**decrement(buckets, sample_rate=1, message=None)**

To decrement one or more stats counters.

	StatsdClient client = new StatsdClient(new AFTransport());
	client.decrement("some.int");
	
And this will send message:

	some.int:-1|c

**update_stats(buckets, delta=1, sampleRate=1, message=None)**

To updates one or more stats counters by arbitrary amounts:

	StatsdClient client = new StatsdClient(new AFTransport());
	client.updateStats(5, "some.int");
	client.updateStats(2, 0.5, "some.int");
	client.updateStats(3, "act1", 1.0, "some.int")
	
And the message for these are:

	some.int:5|c
	some.int:2|c|@0.5
	some.int:3|@1.0|act1

###Sample Rate

Chances are that your application sends lots of counting through UDP/AFTransport which might significantly hurt your performance, Sampling is here to the rescue.

By pass in a `sampleRate`, the client will only sent `(sampleRate * 100)%` of the **counter** messages by **random** and discard the rest "unlucky" ones. The message will carry this rate, and the server will restore the count by multiply `1/sampleRate` upon reception (of course, we lose the precision).

By default the sample_rate is alway 1, which means every message will be sent.

Note this is a **counter** only feature, `sampleRate` for **timer** and **gauge** will be ignored.


## Timing
-------------------
**timing(bucket, elapse, message=None)**

Log timing information, in another word, measuring the elapsed time for a certain action.
Optionally, you can also define message (with **[AppFirst Extended Format](#appfirst-extension)** only).

	StatsdClient client = new StatsdClient(new AFTransport());
	client.timing("some.time", 500);
	client.timing("some.time", 300, "message");

UOM for timing is always 'ms' (milli-second). A message like this is sent:

	some.time:500|ms
	some.time:300|ms||message

## Gauge
-------------------
**gauge(bucket, reading, message=None)**

Log gauge information, in another word, the status of the moment. The client will send the message with a timestamp of now.

	StatsdClient client = new StatsdClient(new AFTransport());
	client.gauge("some.gauge", 500);

The unit for gauge is 'g', here is the message:

	some.gauge:500|g

Again, you can also define message (with **[AppFirst Extended Format](#appfirst-extension)** only)
	

## About Transport
-------------------
In order to switch between different ways of sending statsd message, we have the concept Transport. Currently we have `UDPTransport` by default in client.py and `AFTransport` by default in afclient if you want to communicate with [AppFirst Collector][collector].


To implement your own transport, implement `com.appfirst.statsd.Transport`.

## Namespace
-------------------
TBD


[collector]: https://wwws.appfirst.com
