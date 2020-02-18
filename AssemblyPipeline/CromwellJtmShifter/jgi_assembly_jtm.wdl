workflow jgi_meta {
    File input_file
    Float uniquekmer=1000
    String bbtools_container="bryce911/bbtools:38.44"
    String spades_container="bryce911/spades:3.13.0"
    String basic_container="bryce911/bbtools:38.44"
    call bbcms {
          input: infile=input_file, container=bbtools_container
    }
    call assy {
         input: infile1=bbcms.out1, infile2=bbcms.out2, container=spades_container
    }
    call create_agp {
         input: scaffolds_in=assy.out, container=bbtools_container
    }
    call read_mapping_pairs {
     input: reads=input_file, ref=create_agp.outcontigs, container=bbtools_container
    }

}
#AWS_uswest2-optimal-ceq
task read_mapping_pairs{
    File reads
    File ref
    String container
  

    String filename_resources="resources.log"
    String filename_unsorted="pairedMapped.bam"
    String filename_outsam="pairedMapped.sam.gz"
    String filename_sorted="pairedMapped_sorted.bam"
    String filename_sorted_idx="pairedMapped_sorted.bam.bai"
    String filename_bamscript="to_bam.sh"
    String filename_cov="covstats.txt"
    String dollar="$"
    #runtime { backend: "JTM"}
    runtime {
	poolname: "aim2_assembly"
        cluster: "cori"
        time: "06:00:00"
        cpu: 32
        mem: "115GB"
        node: 1
        nwpn: 4
    }
    command{
    	echo $(curl --fail --max-time 10 --silent http://169.254.169.254/latest/meta-data/public-hostname)
        touch ${filename_resources};
	curl --fail --max-time 10 --silent https://bitbucket.org/berkeleylab/jgi-meta/get/master.tar.gz | tar --wildcards -zxvf - "*/bin/resources.bash" && ./*/bin/resources.bash > ${filename_resources} &
        sleep 30

        set -eo pipefail
	shifter --image=${container} -- bbmap.sh -Xmx105g threads=${dollar}(grep "model name" /proc/cpuinfo | wc -l) nodisk=true interleaved=true ambiguous=random in=${reads} ref=${ref} out=${filename_unsorted} covstats=${filename_cov} bamscript=${filename_bamscript}
	shifter --image=${container} -- samtools sort -m100M -@ ${dollar}(grep "model name" /proc/cpuinfo | wc -l) ${filename_unsorted} -o ${filename_sorted}
        shifter --image=${container} -- samtools index ${filename_sorted}
        shifter --image=${container} -- reformat.sh -Xmx105g in=${filename_unsorted} out=${filename_outsam} overwrite=true
  }
  output{
      File outbamfile = filename_sorted
      File outbamfileidx = filename_sorted_idx
      File outcovfile = filename_cov
      File outsamfile = filename_outsam
      File outresources = filename_resources
  }
}

task create_agp {
    File scaffolds_in
    String container

    String filename_resources="resources.log"
    String prefix="assembly"
    String filename_contigs="${prefix}.contigs.fasta"
    String filename_scaffolds="${prefix}.scaffolds.fasta"
    String filename_agp="${prefix}.agp"
    String filename_legend="${prefix}.scaffolds.legend"
    #runtime {backend: "JTM"}
    runtime {
        poolname: "aim2_assembly"
        cluster: "cori"
        time: "01:00:00"
        cpu: 32
        mem: "115GB"
        node: 1
        nwpn: 4
    }
    command{
	echo $(curl --fail --max-time 10 --silent http://169.254.169.254/latest/meta-data/public-hostname)
        touch ${filename_resources};
	curl --fail --max-time 10 --silent https://bitbucket.org/berkeleylab/jgi-meta/get/master.tar.gz | tar --wildcards -zxvf - "*/bin/resources.bash" && ./*/bin/resources.bash > ${filename_resources} &	
        sleep 30

	shifter --image=${container} -- fungalrelease.sh -Xmx105g in=${scaffolds_in} out=${filename_scaffolds} outc=${filename_contigs} agp=${filename_agp} legend=${filename_legend} mincontig=200 minscaf=200 sortscaffolds=t sortcontigs=t overwrite=t
  }
    output{
	File outcontigs = filename_contigs
	File outscaffolds = filename_scaffolds
	File outagp = filename_agp
    	File outlegend = filename_legend
    	File outresources = filename_resources
    }
}

task assy {
     File infile1
     File infile2
     String container

     String filename_resources="resources.log"
     String outprefix="spades3"
     String filename_outfile="${outprefix}/scaffolds.fasta"
     String filename_spadeslog ="${outprefix}/spades.log"
     String dollar="$"
     #runtime {backend: "JTM"}
     runtime {
        poolname: "aim2_assembly"
        cluster: "cori"
        time: "10:00:00"
        cpu: 32
        mem: "115GB"
        node: 1
        nwpn: 4
     }
     command{
	echo $(curl --fail --max-time 10 --silent http://169.254.169.254/latest/meta-data/public-hostname)
        touch ${filename_resources};
	curl --fail --max-time 10 --silent https://bitbucket.org/berkeleylab/jgi-meta/get/master.tar.gz | tar --wildcards -zxvf - "*/bin/resources.bash" && ./*/bin/resources.bash > ${filename_resources} &		
        sleep 30
	
        set -eo pipefail
	shifter --image=${container} -- spades.py --tmp-dir /tmp -m 2000 -o ${outprefix} --only-assembler -k 33,55,77,99,127  --meta -t ${dollar}(grep "model name" /proc/cpuinfo | wc -l) -1 ${infile1} -2 ${infile2}
     }
     output {
            File out = filename_outfile
            File outlog = filename_spadeslog
            File outresources = filename_resources
     }
}

task bbcms {
     File infile
     String container

     String filename_resources="resources.log"
     String filename_outfile="input.corr.fastq.gz"
     String filename_outfile1="input.corr.left.fastq.gz"
     String filename_outfile2="input.corr.right.fastq.gz"
     String filename_readlen="readlen.txt"
     String filename_outlog="stdout.log"
     String filename_errlog="stderr.log"
     String filename_kmerfile="unique31mer.txt"
     String filename_counts="counts.metadata.json"
     String dollar="$"
     #runtime { backend: "JTM"}
     runtime {
        poolname: "aim2_assembly"
        cluster: "cori"
        time: "06:00:00"
        cpu: 32
        mem: "115GB"
        node: 1
        nwpn: 4
     }

     command {
        echo $(curl --fail --max-time 10 --silent http://169.254.169.254/latest/meta-data/public-hostname)
        touch ${filename_resources};
	curl --fail --max-time 10 --silent https://bitbucket.org/berkeleylab/jgi-meta/get/master.tar.gz | tar --wildcards -zxvf - "*/bin/resources.bash" && ./*/bin/resources.bash > ${filename_resources} &		
        sleep 30

        set -eo pipefail
	shifter --image=${container} -- bbcms.sh -Xmx105g  metadatafile=${filename_counts} mincount=2 highcountfraction=0.6 in=${infile} out=${filename_outfile} > >(tee -a ${filename_outlog}) 2> >(tee -a ${filename_errlog} >&2) && grep Unique ${filename_errlog} | rev |  cut -f 1 | rev  > ${filename_kmerfile}
	shifter --image=${container} -- reformat.sh -Xmx105g in=${filename_outfile} out1=${filename_outfile1} out2=${filename_outfile2}
	shifter --image=${container} -- readlength.sh -Xmx105g in=${filename_outfile} out=${filename_readlen}
     }
     output {
            File out = filename_outfile
            File out1 = filename_outfile1
            File out2 = filename_outfile2
            File outreadlen = filename_readlen
            File stdout = filename_outlog
            File stderr = filename_errlog
            File outcounts = filename_counts
            File outkmer = filename_kmerfile
            File outresources = filename_resources
     }
}
