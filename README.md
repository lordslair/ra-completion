foobar
======

Some script without any big purposes, just usefull ones

### count-files-from-dir.pl

Small script to count files in a path and the subdirectories

	Syntax: count-files-from-dir.pl [-h|-v] --path=<PATH>
	  -h, --help                           this help                              |
	  -v, --verbose                        increase verbosity                     |
	
	Options :
	------------
	  -m, --min   <MAX>                    we output results when count > min     | default : 1000
	  -p, --path  <PATH>                   path you want to analyze               | /!\ Mandatory

### clean-rom.pl

Small script to sort files from a full set so keep only the best ROM

	Syntax: clean-rom.pl [-h|-v] --path=<PATH>
	  -h, --help                           this help                              |
	  -v, --verbose                        increase verbosity                     |
	
	Options :
	------------
	  -p, --path  <PATH>                   path you want to analyze               | /!\ Mandatory
	  -d, --dest  <PATH>                   path where you want to put the roms    | /!\ Mandatory
