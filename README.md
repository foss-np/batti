# batti [:link:][web]

load-shedding information.

![screenshot][screenshot]

#### Setting up

batti depends upon [2utf8][2utf8] to process non-unicode data,
which is now included in git [sub-module][submodule].


```bash

    $ git clone https://github.com/foss-np/batti
    $ cd batti
    $ git submodule init
    $ git submodule update
```


**Tip**: Add `alias batti="/path/to/batti/main.sh"` to your *.bashrc* so you can run `$ batti -g [GROUP_NO]`


#### HOW-TO USE

```bash

    $ batti -h
    Usage: 	batti -g [1-7] [OPTIONS]
   	    -g | --group    Group number 1-7
	    -t | --today    Show todays schedule [uses with group no]
	    -w | --week     Show weeks schedule [default]
	    -u | --update	Check for update [ignores extra options]
		-x |  --xml     Dump to xml"
   	    -h | --help     Display this message
```

#### Plugin

**to add plugin to [conky-forever][conky-forever]**:

```bash
	$ echo "_conky_forever=/path/to/conky-forever" >> path.config
	$ ./conky_plugin.sh [GROUP_NO]
```

#### HOW-IT Works

* Downloads schedule form [nea][nea]
* Extract schedule and put into `~/.cache/batti.sch`
* Processes your query

[nea]: http://www.nea.org.np/loadshedding.html
[2utf8]: https://github.com/foss-np/2utf8
[conky-forever]: https://github.com/rhoit/conky-forever
[submodule]: http://git-scm.com/book/en/Git-Tools-Submodules
[web]: http://foss-np.github.io/batti/
[screenshot]: https://raw.github.com/foss-np/batti/gh-pages/images/screenshot.png
