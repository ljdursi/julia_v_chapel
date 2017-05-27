proc main() {
  config const numTasks = here.numCores;

  coforall tid in 0..#numTasks {
	  writeln(tid);
  }

  coforall loc in Locales {
     on loc {
		writeln(loc.id, loc.name)
	}
}
