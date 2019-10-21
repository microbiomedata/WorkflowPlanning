workflow assembly{
	Boolean DoQC
	Int cpu
	String outdir
	String? QCopts=""
	String Assembler="megahit"  # megahit or metaspades
	String? AssemblerOpts=""
	Array[String] PairedReads=[]
	String? SingleRead
	
	if (DoQC){
		call qc{
			input: opts = QCopts,
			cpu = cpu,
			outdir = outdir,
			QCPairedReads = PairedReads,
			QCSingleRead = SingleRead
		}
	}

	call run_assembly{
		input: opts = AssemblerOpts,
		cpu = cpu,
		outdir = outdir,
		assembler = Assembler,
		PairedReads = if DoQC then qc.QCedPaired else PairedReads,
		SingleRead = if DoQC then qc.QCedSingle else SingleRead
	}

#	call annotation{
#	}
	meta {
		author: "Chienchi Lo"
		email: "chienchi@lanl.gov"
		version: "0.0.1"
	}
}

task qc{
	Array[String] QCPairedReads
	String? QCSingleRead
	String opts
	Int cpu
	String outdir
	command {
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		mkdir -p ${outdir}
		if [ -f "${QCPairedReads[0]}" ]; then
			FaQCs -1 ${QCPairedReads[0]} -2 ${QCPairedReads[1]} -d ${outdir}/QC -t ${cpu} ${opts}
		fi
		if [ -f "${QCSingleRead}" ]; then
			FaQCs -u ${QCSingleRead} -d ${outdir}/QC -t ${cpu} ${opts}
		fi
		if [ ! -f "${QCPairedReads[0]}" -a ! -f "${QCSingleRead}" ]; then
			echo "No input files for QC"
			exit 
		fi
	}
	output{
		Array[File] QCedPaired = ['${outdir}/QC/QC.1.trimmed.fastq','${outdir}/QC/QC.2.trimmed.fastq']
		File QCedSingle = "${outdir}/QC/QC.unpaired.trimmed.fastq"
		File QCstat = "${outdir}/QC/QC.stats.txt"
		File QCstatPDF = "${outdir}/QC/QC_qc_report.pdf"
	}
	runtime{ memory: "20 GB"
                 cpu: cpu}

}

task run_assembly{
	String assembler
	Int cpu
 	String opts
 	Array[String] PairedReads
	String? SingleRead
	Int mem = 100
 	Int minLen = 500
	String outdir
	command {
		source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		mkdir -p ${outdir}
		if [ -f "${PairedReads[0]}" ]; then
			metawrap assembly -1 ${PairedReads[0]} -2 ${PairedReads[1]} -l ${minLen} -o ${outdir}/assembly -m ${mem}  ${"--" + assembler} -t ${cpu} 
		fi
		## Not support single end reads
		#if [ -f "${SingleRead}" ]; then
		#	metawrap assembly -1 ${PairedReads[0]} -2 ${PairedReads[1]} ${"--" + assembler} -t ${cpu} -o ${outdir}/assembly -m ${mem} -l ${minLen}
		#fi
	}


	output {
		File contig = '${outdir}/assembly/final_assembly.fasta'
		File quastPDf = '${outdir}/assembly/QUAST_out/report.pdf'
		File quastHTML = '${outdir}/assembly/assembly_report.html'
	}
        runtime{ memory: mem + "GB"
                 cpu: cpu}
}

#task annotation{
#
#	command{
#		echo "Run prokka"
#	}
#}
