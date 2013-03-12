# batti

load-shedding information.

#### Dependencies

batti depends upon [2utf8][2utf8] to process non-unicode data.

**to download [2utf8][2utf8] do the following**:

	$ git clone https://github.com/foss-np/2utf8.git /path/to/local/machine
	$ echo "_2utf8=path/to/local/machine" > path.config
[Note: The path should be relative not absolute ]

#### HOW-TO USE
	
	$ ./main.sh [GROUP_NO]

#### HOW-IT Works

* Downloads schedule form [nea][nea]
* Extract schedule
* Processes your query

#### TODO
* Coloring/Hilighting particular time and date.

[nea]: http://www.nea.org.np/loadshedding.html
[2utf8]: https://github.com/foss-np/2utf8
