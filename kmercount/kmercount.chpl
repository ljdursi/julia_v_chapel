use IO;

config const input_filename = "input.fa",
             k = 11;

proc main(args: [] string) {
  var sequences = readfasta(input_filename);

  var kmers : domain(string);
  var kmer_counts: [kmers] int;

  for sequence in sequences {
    for i in 1..(sequence.length-k+1) {
      var kmer: string = sequence[i..#k];   // k-long, starting at i
      if !kmers.member(kmer) {
        kmer_counts[kmer] = 0;
      } 
      kmer_counts[kmer] += 1;
    } 
  }

  for kmer in kmers {
    writeln(kmer, " ", kmer_counts[kmer]);
  }
}

proc readfasta(filename) {
  var sequencelist: domain(1) = 1..1;
  var sequences : [sequencelist] string;

  var infile = open(filename, iomode.r);
  var reader = infile.reader();

  var nseq = 0;
  var success : bool = true;
  var inseq : bool = false;
  var currentseq : string = "";
  do {
    var line: string = "";
    var err: syserr;
    success = reader.readline(line, err);
    if success {
      if line.startsWith(">") {
        if inseq {
          nseq += 1;
          sequences[nseq] = currentseq;
          sequencelist = 1..nseq+1;
          currentseq = "";
        } 
        inseq = false;
      } else {
        inseq = true;
        currentseq += line.strip(" \t\r\n", true, true);
      }
    }  
  } while (success);
  if inseq {
    nseq += 1;
    sequences[nseq] = currentseq;
    sequencelist = 1..nseq+1;
    currentseq = "";
  } 
  
  return sequences;
}
