workflow MAGgeneration {
	Boolean DoReassemble=false
	Boolean Doblobology=false
	Boolean Dobin_taxonomy=false
	Int cpu
	Array[File] PairedReads=[]
	File? SingleRead
	File Contig
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
		binning_pwd = binning.binning_dir
	}
	
	if (Doblobology){ 
		call blobology{
			input: cpu=cpu,
			outdir = outdir,
			assembly_file = Contig,
			PairedReads = PairedReads,
			SingleRead = SingleRead,
			refinebin_pwd = refine_bins.refinebin_dir
		}
	}
	call abundance{
		input: cpu=cpu, 
		outdir = outdir,
                assembly_file = Contig,
                PairedReads = PairedReads,
                SingleRead = SingleRead,
		refinebin_pwd = refine_bins.refinebin_dir
	}
	if (DoReassemble){
		call reassemble{
			input: cpu=cpu,
			outdir = outdir,
			PairedReads = PairedReads,
			refinebin_pwd = refine_bins.refinebin_dir
		}
	}
	if (Dobin_taxonomy){
		call bin_taxonomy{
			input: cpu=cpu,
			outdir = outdir,
			bin_pwd = if (DoReassemble) then reassemble.reassemble_dir else refine_bins.refinebin_dir
		}
	}
	call bin_annotation{
		input: cpu=cpu,
		outdir = outdir,
		bin_pwd = if (DoReassemble) then reassemble.reassemble_dir else refine_bins.refinebin_dir
	}
	call make_output{
		input: outdir = outdir,
		binning_stat = binning.dummy_finished,
		refine_bin_stat = refine_bins.stats, 
		blobology_out = blobology.outfile,
		reassemble_stat = reassemble.stats,
		taxonomy_out = bin_taxonomy.taxonomy_tab,
		abundance_table = abundance.abund_table,
		annotation_files = bin_annotation.dummy_finished
	}
	meta {
		author: "Chienchi Lo"
		email: "chienchi@lanl.gov"
		version: "0.0.1"
	}
}

task binning{
	Array[File] PairedReads
	File? SingleRead
	File assembly_file
	String outdir
	Int cpu
	command {
		#mkdir -p ${outdir}
		if [ -f "${outdir}/INITIAL_BINNING/binning.finished" ]; then exit; fi
		## require _1.fastq and _2.fastq format
		if [ -f "${PairedReads[0]}" ]; then
			ln -fs ${PairedReads[0]} read_1.fastq
			ln -fs ${PairedReads[1]} read_2.fastq
			metawrap binning -o INITIAL_BINNING -t ${cpu} -a ${assembly_file} --metabat2 --maxbin2 --concoct read*fastq
		fi
		if [ -f "${SingleRead}" ]; then
			ln -fs ${SingleRead} read.fastq
			metawrap binning --single-end -o INITIAL_BINNING -t ${cpu} -a ${assembly_file} --metabat2 --maxbin2 --concoct read*fastq
		fi
		if [ ! -f "${PairedReads[0]}" -a ! -f "${SingleRead}" ]; then
			echo "No input files for QC"
			exit 
		fi
		touch INITIAL_BINNING/binning.finished
		pwd > binning_pwd.txt 
	}
	output{
		File binning_dir="INITIAL_BINNING"
		File dummy_finished="INITIAL_BINNING/binning.finished"
	}
	runtime{ memory: "20 GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
    }

}

task refine_bins{
	File binning_pwd
	Int cpu
	Int mem = 40
	String outdir
 	Int minCompletion =  70
	Int maxContamination = 10
	#-c INT          minimum % completion of bins [should be >50%] (default=70)
	#-x INT          maximum % contamination of bins that is acceptable (default=10)

	command {
		#source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		export TMPDIR=/tmp
		if [ -f "${outdir}/BIN_REFINEMENT/metawrap_${minCompletion}_${maxContamination}_bins.stats" ]; then exit; fi
		path=${binning_pwd}
		metawrap bin_refinement -o BIN_REFINEMENT -t ${cpu} -A $path/metabat2_bins/ -B $path/maxbin2_bins/ -C $path/concoct_bins/ -c ${minCompletion} -x ${maxContamination} -m ${mem}
		ln -fs metawrap_${minCompletion}_${maxContamination}_bins BIN_REFINEMENT/metawrap_bins
		pwd > refine_bins_pwd.txt
	}


	output {
		File stats = 'BIN_REFINEMENT/metawrap_${minCompletion}_${maxContamination}_bins.stats'
		File png = 'BIN_REFINEMENT/figures/binning_results.png'
		String refinebin_pwd = read_string("refine_bins_pwd.txt")
		File refinebin_dir = "BIN_REFINEMENT"
	}
	runtime{ memory: mem + "GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
	}
}

task blobology{
	Int mem = 40
	Int cpu
	String outdir
	File refinebin_pwd
	File assembly_file
	Array[File] PairedReads
	File? SingleRead
	command {
		#source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
	if [ -f "${PairedReads[0]}" ]; then
            ln -fs ${PairedReads[0]} read_1.fastq
            ln -fs ${PairedReads[1]} read_2.fastq
        fi      
        if [ -f "${SingleRead}" ]; then
            ln -fs ${SingleRead} read.fastq
        fi
		path=${refinebin_pwd}
		metawrap blobology -a ${assembly_file} -t ${cpu} -o BLOBOLOGY --bins $path/metawrap_bins read*fastq
	}
	
	output {
		File outfile = 'BLOBOLOGY/final_assembly.binned.blobplot'
	}
	runtime{ memory: mem + "GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
             # require NCBI_NT_DB database
             # database: '/global/cfs/projectdirs/m3408/aim2/database'
    }
}

task abundance{
	Int mem = 40
	Int cpu
	String outdir
	File refinebin_pwd
	File assembly_file
	Array[File] PairedReads
	File? SingleRead
	Int minCompletion =  70
	Int maxContamination = 10
	command{
		if [ -f "${PairedReads[0]}" ]; then 
			ln -fs ${PairedReads[0]} read_1.fastq
			ln -fs ${PairedReads[1]} read_2.fastq
        	fi      
        	if [ -f "${SingleRead}" ]; then
			ln ${SingleRead} read.fastq
		fi
		path=${refinebin_pwd}
		metawrap quant_bins -t ${cpu} -b $path/metawrap_${minCompletion}_${maxContamination}_bins -o QUANT_BINS -a ${assembly_file} read*fastq
	}
	output{
		File abund_table = "QUANT_BINS/bin_abundance_table.tab"
	}
    runtime{ memory: mem + "GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
    }
}

task reassemble{
	Int mem = 40
	Int cpu
	String outdir
	Array[File] PairedReads
	File refinebin_pwd
	Int minCompletion =  70
	Int maxContamination = 10
	command{
		# doesn't support single end reads https://github.com/bxlab/metaWRAP/issues/94
		export TMPDIR=/tmp
		path=${refinebin_pwd}
		metawrap reassemble_bins -o BIN_REASSEMBLY -1 ${PairedReads[0]} -2 ${PairedReads[1]} -t ${cpu} -m ${mem} -c ${minCompletion} -x ${maxContamination} -b $path/metawrap_${minCompletion}_${maxContamination}_bins
		pwd > reassemble_pwd.txt
	}

	output{
		File stats = "BIN_REASSEMBLY/reassembled_bins.stats"
		File png = "BIN_REASSEMBLY/reassembled_bins.png"
		String reassemble_pwd = read_string("reassemble_pwd.txt")
		File reassemble_dir = "BIN_REASSEMBLY"
	}
    runtime{ memory: mem + "GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
           #database: '/global/cfs/projectdirs/m3408/aim2/database'
    }
}

task bin_taxonomy{
	Int mem = 40
	Int cpu
	String outdir
	File bin_pwd
	command{
		path=${bin_pwd}
		if [ -d "$path/reassembled_bins" ]; then
			metawrap classify_bins -b $path/reassembled_bins -o BIN_CLASSIFICATION -t ${cpu}
		else
			metawrap classify_bins -b $path/metawrap_bins -o BIN_CLASSIFICATION -t ${cpu}
		fi
	}
	output{
		File taxonomy_tab = "BIN_CLASSIFICATION/bin_taxonomy.tab"
	}
	runtime{ memory: mem + "GB"
             cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
              # NT database
             # database: '/global/cfs/projectdirs/m3408/aim2/database'
	}
}

task bin_annotation{
	Int mem = 40
	Int cpu
	String outdir
	File bin_pwd
	command{
		path=${bin_pwd}
		if [ -d "$path/reassembled_bins" ]; then
			metawrap annotate_bins -o FUNCT_ANNOT -t ${cpu} -b $path/reassembled_bins
		else
			metawrap annotate_bins -o FUNCT_ANNOT -t ${cpu} -b $path/metawrap_bins
		fi
		touch FUNCT_ANNOT/annotation.finished
	}
	output{
		File dummy_finished = "FUNCT_ANNOT/annotation.finished"
	}

	runtime{ memory: mem + "GB"
                cpu: cpu
             docker: 'bioedge/nmdc_mags:withchkmdb'
	}
}

task make_output{
	String outdir
	String binning_stat
	String refine_bin_stat
	String abundance_table
	String? blobology_out = "NotExistFile"
	String? reassemble_stat = "NotExistFile"
	String? taxonomy_out = "NotExistFile"
	String annotation_files
	
	command{
		mkdir -p ${outdir}
		binning_path=`dirname ${binning_stat}`
		refine_bing_path=`dirname ${refine_bin_stat}`
		abundance_path=`dirname ${abundance_table}`
		annotation_path=`dirname ${annotation_files}`
		mv -f $binning_path ${outdir}/
		mv -f $refine_bing_path ${outdir}/
		mv -f $abundance_path ${outdir}/
		mv -f $annotation_path ${outdir}/
		[ ! -z "$binning_path" ] && rm -rf $binning_path/../../
		[ ! -z "$refine_bing_path" ] && rm -rf $refine_bing_path/../../
		[ ! -z "$abundance_path" ] && rm -rf $abundance_path/../../
		[ ! -z "annotation_path" ] && rm -rf $annotation_path/../../
		if [ -f ${blobology_out} ]; then
			blobology_path = `dirname ${blobology_out}`
			mv -f $blobology_path ${outdir}/
			[ ! -z "$blobology_path" ] && rm -rf  $blobology_path/../../
		fi
		if [ -f ${reassemble_stat} ]; then
			reassemble_path = `dirname ${reassemble_stat}`
			mv -f $reassemble_path ${outdir}/
			[ ! -z "$reassemble_path" ] && rm -rf $reassemble_path/../../
		fi
		if [ -f ${taxonomy_out} ]; then
			taxonomy_path = `dirname ${taxonomy_out}`
			mv -f $taxonomy_path ${outdir}/
			[ ! -z "$taxonomy_path" ] && rm -rf $taxonomy_path/../../
		fi
		chmod 764 -R ${outdir}
	}
}
