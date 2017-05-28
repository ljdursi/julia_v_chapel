proc main() {
  const numTasks = here.numPUs();
  for taskid in 0..#numTasks {
      begin {
          writeln(here.id, " ", here.name, " ", taskid);
      }
  }

  coforall loc in Locales {
    on loc {
      writeln(loc.id, " ", loc.name);
    }
  }
}
