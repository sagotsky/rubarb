Description
====================

Rubarb runs a bunch of shell scripts, pieces them together according to a customizable template, and pipes them into your bar of choice.  It was inspired by xmobar, but designed to work independently of any particular WM.  

Goals
--------------------

This piece of software is deliberately overengineered.  As a rails dev, I don't get a lot of chances to play with some of the cool toys that Ruby offers.  I'm playing with them here so that I don't have to use them at work.  Some things I'm doing just for shits and giggles include:

* Write a DSL
* Use metaprogramming
* Manage several threads
* Define a plugin system
* Read from a config file
 * The config file is secretly Ruby, but should be configurable by non-programmers.  Did I mention a DSL?

Implementation
--------------------

Scan the template
Make a thread per executable
Whenever a thread returns, cache its last line and trigger a redraw
Redraw: swap in last cached line onto template
(respawn if a thread dies/finishes?)

Open Questions
--------------------

1. Should the scripts take args?  Instead of date.sh can I call `/usr/bin/date +F...`
2. Include a respawn timeout?  Some scripts will crash.  Others should run once instead of requiring a watch or a loop in each script
3. Error reporting on STDERR?
4. Is format redundant with the template insert coming up later?  Or is it making the template easier to deal with since it's just names instead of logic?
5. How to get output var into format block?  Is that a method on the dsl?
6. Likewise, how to get all those template vars into the template block?  More methods?  Abuse of method_missing?
  instance_exec + @instance_vars perhaps?

Example ruby config (not all these options are implemented - consider this a sketch of what I'd like the config to look like)
====================

```ruby
# run a script by name from the ~/.rubarb dir
run :script
run 'script.sh'
run 'date +F %m/%d/%y'

# Run a script with a custom respawn.  Something like date
run :returning_script { 
  respawn 60
}
# or hash style
run :returning_script, {respawn: 60}

# change the name for the template
run :yet_another_script {
  name 'foo'
}

# color formatter for a made up bar color formatter
run :colorful_output {
  format { "^fg=red#{output}^fg" }
}

run :interesting_output {
  format { 
    color = output.even? ? 'red' : 'blue'
    "^fg=#{color}#{output}^fg"
}

run :icon_script {
  icon '/path/to/xbm'     # only show this icon if the script has output
  symbol ':)'             # ditto
}

com :clock {
  #can\'t use format again...
  # there are some commands that should just call ruby methods instead of forking processes....
}

template {
  "#{stdin} #{script} - #{returning_script} ^right #{interesting_output}"
}
```

