#import "https://portal.nersc.gov/project/m3408/wdl/structural-annotation.wdl" as sa
#import "https://portal.nersc.gov/project/m3408/wdl/functional-annotation.wdl" as fa
import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow annotation {
  String  imgap_input_file
  String  imgap_project_id
  Int     additional_threads=72
  Boolean sa_execute=true
  Boolean fa_execute=true

  call setup {
    input:
      file = imgap_input_file
  }

  scatter(split in setup.splits) {

    if(sa_execute) {
      call sa.s_annotate {
        input:
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_input_fasta = split
      }
    }

    if(fa_execute) {
      call fa.f_annotate {
        input:
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          sa_gff = s_annotate.gff,
          input_fasta = s_annotate.proteins
      }
    }
  }
}

task setup {
  String file

  command {
    python <<CODE
    import os
    chunksize = 10*1024*1024

    infile = "${file}"
    chunk = 1

    fin = open(infile)

    done = False
    while not done:
       outf = '%s.%d' % (os.path.basename(infile), chunk)
       print(outf)
       fout = open(outf, 'w')
       data = fin.read(chunksize)
       fout.write(data)
       if len(data) < chunksize:
           done = True
       while True:
          line = fin.readline()
          if line.startswith('>') or len(line)==0:
             fin.seek(fin.tell()-len(line), 0)
             break
          fout.write(line)
       chunk += 1

    CODE
    }

  output {
    Array[File] splits = read_lines(stdout())
  }
}

