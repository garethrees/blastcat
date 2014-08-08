Blastcat
========

Usage
-----

Download and install the [blast command line tools](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/).

Open iTerm and type each of the following commands (the `$` represents a new command).

```sh
$ cd ~/Dropbox/blastcat2
$ ./start
```

Once shotgun is running visit <http://localhost:9393> in your browser.

Happy blasting!

It Doesn't Work!
----------------

If you get an error along the lines of "port already in use", it may be that
`shotgun` didn't exit properly. Try killing all ruby processes first:

```sh
$ killall ruby
$ ./start
```


