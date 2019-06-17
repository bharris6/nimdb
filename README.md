# nimdb
An attempt to replicate Redis key-value store functionality using nim.

Inspired by http://charlesleifer.com/blog/building-a-simple-redis-server-with-python/

## Install

Only depends on the standard `nim` modules, so you don't need to do anything beyond cloning this repository and having `nim` installed.

## Run

First run:

`nim c -r nimdb.nim`  

Subsequent runs: 

`./nimdb`

## Commands

Right now, the only "mode"/datatype is a simple string of the format `+COMMAND <ARG1> <ARG2> ... <ARGN>`.  Default port is 12345.

### GET \<key\>

Get a value for a specific key.  Returns the key on success, "KO" on failure.

### SET \<key\> \<value\>
  
Sets a value for a specific key.  Returns "OK" on success, "KO" on failure.

### MGET \<key1\> \<key2\> ... \<keyn\>
  
Gets values for all provided keys.  Returns space-separated string "<value1> <value2> ... <valuen>"
  
### MSET \<key1\> \<value1\> \<key2\> \<value2\> ... \<keyn\> \<valuen\>
  
Sets values for all provided keys.  Returns "OK" on success, "KO" on failure.

### FLUSH

Clears all key-value pairs.
