proc main() {
  const numTasks = here.numPUs();
  coforall tid in 0..#numTasks {
      writeln(here.id, " ", here.name, " ", tid);
  }

  coforall loc in Locales {
    on loc {
      writeln(loc.id, " ", loc.name);
    }
  }
}
