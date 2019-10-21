workflow MAGgeneration {
	Boolean DoReassemble=false
	Boolean Doblobology=false
	Boolean Dobin_taxonomy=false
	Int cpu
	Array[String] PairedReads=[]
	String? SingleRead
	String Contig
	String outdir
	
	call binning{
		input: cpu = cpu,
		outdir = outdir,
		PairedReads = PairedReads,
		SingleRead = SingleRead,
		assembly_file = Contig
	}

	call refine_bins{
		input: cpu = cpu,
		outdir = outdir,
		binning_dummy_file = binning.dummy_finished
	}
	if (Doblobology){ 
		call blobology{
			input: cpu=cpu,
			outdir = outdir,
			assembly_file = Contig,
			PairedReads = PairedReads,
			SingleRead = SingleRead,
			refinebin_stats = refine_bins.stats
		}
	}
	call abundance{
		input: cpu=cpu, 
		outdir = outdir,
                assembly_file = Contig,
                PairedReads = PairedReads,
                SingleRead = SingleRead,
                refinebin_stats = refine_bins.stats
	}
	if (DoReassemble){
		call reassemble{
			input: cpu=cpu,
			outdir = outdir,
			PairedReads = PairedReads,
			refinebin_stats = refine_bins.stats
		}
	}
	if (Dobin_taxonomy){
		call bin_taxonomy{
			input: cpu=cpu,
			outdir = outdir,
			bin_stats = if (DoReassemble) then reassemble.stats else refine_bins.stats
		}
	}
	call bin_annotation{
		input: cpu=cpu,
		outdir = outdir,
		bin_stats = if (DoReassemble) then reassemble.stats else refine_bins.stats
	}
	meta {
		author: "Chienchi Lo"
		email: "chienchi@lanl.gov"
		version: "0.0.1"
	}
}

task binning{
	Array[String] PairedReads
	String? SingleRead
	String assembly_file
	String outdir
	Int cpu
	command {
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		mkdir -p ${outdir}
		if [ -f "${outdir}/INITIAL_BINNING/binning.finished" ]; then exit; fi
		## require _1.fastq and _2.fastq format
		if [ -f "${PairedReads[0]}" ]; then
			ln -fs ${PairedReads[0]} read_1.fastq
			ln -fs ${PairedReads[1]} read_2.fastq
			metawrap binning -o ${outdir}/INITIAL_BINNING -t ${cpu} -a ${assembly_file} --metabat2 --maxbin2 --concoct read*fastq
		fi
		if [ -f "${SingleRead}" ]; then
			ln -fs ${SingleRead} read.fastq
			metawrap binning --single-end -o ${outdir}/INITIAL_BINNING -t ${cpu} -a ${assembly_file} --metabat2 --maxbin2 --concoct read*fastq
		fi
		if [ ! -f "${PairedReads[0]}" -a ! -f "${SingleRead}" ]; then
			echo "No input files for QC"
			exit 
		fi
		touch ${outdir}/INITIAL_BINNING/binning.finished
	}
	output{
		File dummy_finished = "${outdir}/INITIAL_BINNING/binning.finished"
	}
	runtime{ memory: "20 GB"
                 cpu: cpu}

}

task refine_bins{
	String binning_dummy_file
	Int cpu
	Int mem = 40
	String outdir
 	Int minCompletion =  70
	Int maxContamination = 10
	#-c INT          minimum % completion of bins [should be >50%] (default=70)
	#-x INT          maximum % contamination of bins that is acceptable (default=10)

	command {
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		export TMPDIR=/tmp
		if [ -f "${outdir}/BIN_REFINEMENT/metawrap_${minCompletion}_${maxContamination}_bins.stats" ]; then exit; fi
		path=`dirname ${binning_dummy_file}`
		metawrap bin_refinement -o ${outdir}/BIN_REFINEMENT -t ${cpu} -A $path/metabat2_bins/ -B $path/maxbin2_bins/ -C $path/concoct_bins/ -c ${minCompletion} -x ${maxContamination} -m ${mem}
		ln -fs ${outdir}/BIN_REFINEMENT/metawrap_${minCompletion}_${maxContamination}_bins ${outdir}/BIN_REFINEMENT/metawrap_bins
	}


	output {
		File stats = '${outdir}/BIN_REFINEMENT/metawrap_${minCompletion}_${maxContamination}_bins.stats'
		File png = '${outdir}/BIN_REFINEMENT/figures/binning_results.png'
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

task blobology{
	Int mem = 40
	Int cpu
	String outdir
	String refinebin_stats
	String assembly_file
	Array[String] PairedReads
        String? SingleRead
	command{
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		if [ -f "${PairedReads[0]}" ]; then
                        ln -fs ${PairedReads[0]} read_1.fastq
                        ln -fs ${PairedReads[1]} read_2.fastq
                fi      
                if [ -f "${SingleRead}" ]; then
                        ln -fs ${SingleRead} read.fastq
                fi
		path=`dirname ${refinebin_stats}`
		metawrap blobology -a ${assembly_file} -t ${cpu} -o ${outdir}/BLOBOLOGY --bins $path/metawrap_bins read*fastq
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

task abundance{
	Int mem = 40
        Int cpu
	String outdir
	String refinebin_stats
	String assembly_file
	Array[String] PairedReads
        String? SingleRead
	command{
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		if [ -f "${PairedReads[0]}" ]; then 
                        ln -fs ${PairedReads[0]} read_1.fastq
                        ln -fs ${PairedReads[1]} read_2.fastq
                fi      
                if [ -f "${SingleRead}" ]; then
                        ln ${SingleRead} read.fastq
                fi  
		path=`dirname ${refinebin_stats}`
		metawrap quant_bins -t ${cpu} -b $path/metawrap_bins -o ${outdir}/QUANT_BINS -a ${assembly_file} read*fastq
	}
	output{
		File abund_table = "${outdir}/QUANT_BINS/bin_abundance_table.tab"
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

task reassemble{
	Int mem = 40
        Int cpu
	String outdir
	Array[String] PairedReads
	String refinebin_stats
	Int minCompletion =  70
        Int maxContamination = 10
	command{
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		# doesn't support single end reads https://github.com/bxlab/metaWRAP/issues/94
		export TMPDIR=/tmp
		path=`dirname ${refinebin_stats}`
		metawrap reassemble_bins -o ${outdir}/BIN_REASSEMBLY -1 ${PairedReads[0]} -2 ${PairedReads[1]} -t ${cpu} -m ${mem} -c ${minCompletion} -x ${maxContamination} -b $path/metawrap_bins
	}
	output{
		File stats = "${outdir}/BIN_REASSEMBLY/reassembled_bins.stats"
		File png = "${outdir}/BIN_REASSEMBLY/reassembled_bins.png"
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

task bin_taxonomy{
	Int mem = 40
        Int cpu
	String outdir
	String bin_stats
	command{
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		path=`dirname ${bin_stats}`
		if [ -d "$path/reassembled_bins" ]; then
			metawrap classify_bins -b $path/reassembled_bins -o ${outdir}/BIN_CLASSIFICATION -t ${cpu}
		else
			metawrap classify_bins -b $path/metawrap_bins -o ${outdir}/BIN_CLASSIFICATION -t ${cpu}
		fi
	}
	output{
		File taxonomy_tab = "${outdir}/BIN_CLASSIFICATION/bin_taxonomy.tab"
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

task bin_annotation{
	Int mem = 40
        Int cpu
	String outdir
	String bin_stats
	command{
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		export LD_LIBRARY_PATH=/panfs/biopan01/edge_prod/lib64:$LD_LIBRARY_PATH
		path=`dirname ${bin_stats}`
		if [ -d "$path/reassembled_bins" ]; then
			metawrap annotate_bins -o ${outdir}/FUNCT_ANNOT -t ${cpu} -b $path/reassembled_bins
		else
			metawrap annotate_bins -o ${outdir}/FUNCT_ANNOT -t ${cpu} -b $path/metawrap_bins
		fi
	}

        runtime{ memory: mem + "GB"
                 cpu: cpu}
}
