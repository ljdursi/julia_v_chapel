use IO;

config const input_filename = "input.fa",
             k = 11;

iter kmers_from_seq(sequence: string, int: k) {
  for i in 1..(sequence.length-k+1) {
      yield sequence[i..(i+k-1)];
  }
}

proc main(args: [] string) {
  var sequences = readfasta(input_filename);

  var kmers : domain(string);
  var kmer_counts: [kmers] int;

  for seq in sequences {
    var kmer: string;
    for kmer in kmers_from_seq(seq, k) {
      if !kmers.member(kmer) {
        kmers += kmer;
        kmer_counts[kmer] = 0;
      } 
      kmer_counts[kmer] += 1;
    } 
  }

  forall kmer in kmers {
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
