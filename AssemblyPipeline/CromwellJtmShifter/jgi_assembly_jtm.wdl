workflow jgi_meta {
    Array[File] input_file
    String? outdir
    String rename_contig_prefix="scaffold"
    Float uniquekmer=1000
    String bbtools_container="microbiomedata/bbtools:38.44"
    String spades_container="microbiomedata/spades:3.13.0"
    String basic_container="microbiomedata/bbtools:38.44"
    call bbcms {
          input: input_files=input_file, container=bbtools_container
    }
    call assy {
         input: infile1=bbcms.out1, infile2=bbcms.out2, container=spades_container
    }
    call create_agp {
         input: scaffolds_in=assy.out, container=bbtools_container, rename_contig_prefix = rename_contig_prefix
    }
    call read_mapping_pairs {
         input: reads=input_file, ref=create_agp.outcontigs, container=bbtools_container
    }
    call make_output {
         input: outdir= outdir, bbcms_output=bbcms.out1, assy_output=assy.out, agp_output=create_agp.outcontigs,mapping_output=read_mapping_pairs.outcovfile
    }

}

task make_output{
 	String outdir
 	String bbcms_output
 	String assy_output
 	String agp_output
 	String mapping_output
 
 	command{
 		if [ ! -z ${outdir} ]; then
 			mkdir -p ${outdir}/final_assembly ${outdir}/bbcms ${outdir}/mapping
 			bbcms_path=`dirname ${bbcms_output}`
 			assy_path=`dirname ${assy_output}`
 			agp_path=`dirname ${agp_output}`
 			mapping_path=`dirname ${mapping_output}`
 			mv -f $bbcms_path/* ${outdir}/bbcms
 			mv -f $assy_path ${outdir}/
 			mv -f $agp_path/* ${outdir}/final_assembly
 			mv -f $mapping_path/* ${outdir}/mapping
 			chmod 764 -R ${outdir}
 		fi
 	}
}

#AWS_uswest2-optimal-ceq
task read_mapping_pairs{
    FArray[File] reads
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

        export TIME="time result\ncmd:%C\nreal %es\nuser %Us \nsys  %Ss \nmemory:%MKB \ncpu %P"
        set -eo pipefail
        if [[ ${reads[0]}  == *.gz ]] ; then
             cat ${sep=" " reads} > infile.fastq.gz
             export mapping_input="infile.fastq.gz"
        fi
        if [[ ${reads[0]}  == *.fastq ]] ; then
             cat ${sep=" " reads} > infile.fastq
             export mapping_input="infile.fastq"
        fi
        shifter --image=${container} -- bbmap.sh -Xmx105g threads=${dollar}(grep "model name" /proc/cpuinfo | wc -l) nodisk=true interleaved=true ambiguous=random in=$mapping_input ref=${ref} out=${filename_unsorted} covstats=${filename_cov} bamscript=${filename_bamscript}
        shifter --image=${container} -- samtools sort -m100M -@ ${dollar}(grep "model name" /proc/cpuinfo | wc -l) ${filename_unsorted} -o ${filename_sorted}
        shifter --image=${container} -- samtools index ${filename_sorted}
        shifter --image=${container} -- reformat.sh -Xmx105g in=${filename_unsorted} out=${filename_outsam} overwrite=true
        rm $mapping_input
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
    String rename_contig_prefix
    String filename_resources="resources.log"
    String prefix="assembly"
    String filename_contigs="${prefix}_contigs.fna"
    String filename_scaffolds="${prefix}_scaffolds.fna"
    String filename_agp="${prefix}.agp"
    String filename_legend="${prefix}_scaffolds.legend"
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
        if [ "${rename_contig_prefix}" != "scaffold" ]; then
            sed -i 's/scaffold/${rename_contig_prefix}_scf/g' ${filename_contigs} ${filename_scaffolds} ${filename_agp} ${filename_legend}
        fi
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
	    export TIME="time result\ncmd:%C\nreal %es\nuser %Us \nsys  %Ss \nmemory:%MKB \ncpu %P"
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
     Array[File] input_files
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

        export TIME="time result\ncmd:%C\nreal %es\nuser %Us \nsys  %Ss \nmemory:%MKB \ncpu %P"
        set -eo pipefail
        if [[ ${input_files[0]}  == *.gz ]] ; then
             cat ${sep=" " input_files} > infile.fastq.gz
             export bbcms_input="infile.fastq.gz"
        fi
        if [[ ${input_files[0]}  == *.fastq ]] ; then
             cat ${sep=" " input_files} > infile.fastq
             export bbcms_input="infile.fastq"
        fi
        shifter --image=${container} -- bbcms.sh -Xmx105g  metadatafile=${filename_counts} mincount=2 highcountfraction=0.6 in=$bbcms_input out=${filename_outfile} > >(tee -a ${filename_outlog}) 2> >(tee -a ${filename_errlog} >&2) && grep Unique ${filename_errlog} | rev |  cut -f 1 | rev  > ${filename_kmerfile}
        shifter --image=${container} -- reformat.sh -Xmx105g in=${filename_outfile} out1=${filename_outfile1} out2=${filename_outfile2}
        shifter --image=${container} -- readlength.sh -Xmx105g in=${filename_outfile} out=${filename_readlen}
        rm $bbcms_input
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
