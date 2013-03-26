# batti

load-shedding information.

#### Dependencies

batti depends upon [2utf8][2utf8] to process non-unicode data,
which is now included in git sub-module.

#### HOW-TO USE

**to see the schedule**:

	$ ./main.sh -g [GROUP_NO]

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
