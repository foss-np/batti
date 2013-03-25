# batti

load-shedding information.

#### Dependencies

batti depends upon [2utf8][2utf8] to process non-unicode data.

**to complete the dependency of [2utf8][2utf8]**:

	$ git clone https://github.com/foss-np/2utf8.git /path/to/local/machine
	$ echo "_2utf8=path/to/local/machine" > path.config
	
	[ Note: sometimes relative might not work ]


#### HOW-TO USE

**to see the schedule**:

	$ ./main.sh [GROUP_NO]

#### Plugin

**to add plugin to [conky-forever][conky-forever]**:

	$ echo "_conky_forever=/path/to/conky-forever" >> path.config
	$ ./conky_plugin.sh [GROUP_NO]

#### HOW-IT Works

* Downloads schedule form [nea][nea]
* Extract schedule
* Processes your query

[nea]: http://www.nea.org.np/loadshedding.html
[2utf8]: https://github.com/foss-np/2utf8
[conky-forever]: https://github.com/rhoit/conky-forever
