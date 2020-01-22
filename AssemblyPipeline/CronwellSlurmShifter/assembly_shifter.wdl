workflow assembly{
	Boolean DoQC
	Int cpu
	String outdir
	String? QCopts=""
	String Assembler="megahit"  # megahit or metaspades
	String? AssemblerOpts=""
	String? projectName = "Assembly"
	Array[File] PairedReads=[]
	File? SingleRead
	
	if (DoQC){
		call qc{
			input: opts = QCopts,
			cpu = cpu,
			projectName = projectName,
			outdir = outdir,
			QCPairedReads = PairedReads,
			QCSingleRead = SingleRead
		}
	}

	call run_assembly{
		input: opts = AssemblerOpts,
		cpu = cpu,
		projectName = projectName,
		outdir = outdir,
		assembler = Assembler,
		PairedReads = if DoQC then qc.QCedPaired else PairedReads,
		SingleRead = if DoQC then qc.QCedSingle else SingleRead
	}

	call make_output{
		input: outdir = outdir,
		qc_stat = qc.QCstat,
		projectName = projectName,
		contig = run_assembly.contig
	}
	meta {
		author: "Chienchi Lo"
		email: "chienchi@lanl.gov"
		version: "0.0.1"
	}
}

task qc{
	Array[File] QCPairedReads
	File? QCSingleRead
	String opts
	Int cpu
	String projectName
	String outdir
	Int pairedNumber = length(QCPairedReads)
	command {
		#source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		#mkdir -p ${outdir}
		if [ ${pairedNumber} -eq 2 ]; then
			shifter --image=docker:bioedge/nmdc_mags:withchkmdb FaQCs -1 ${sep=" -2 " QCPairedReads} -d QC -t ${cpu} ${opts}
		else
			# presume interleaved format
			mkdir -p QC
			seqtk seq -1 ${QCPairedReads[0]} > QC/read_1.fastq
			seqtk seq -2 ${QCPairedReads[0]} > QC/read_2.fastq
			shifter --image=docker:bioedge/nmdc_mags:withchkmdb FaQCs -1 QC/read_1.fastq -2 QC/read_2.fastq -d QC -t ${cpu} ${opts}
		fi
		if [ -f "${QCSingleRead}" ]; then
			shifter --image=docker:bioedge/nmdc_mags:withchkmdb FaQCs -u ${QCSingleRead} -d QC -t ${cpu} ${opts}
		fi
		if [ ! -f "${QCPairedReads[0]}" -a ! -f "${QCSingleRead}" ]; then
			echo "No input files for QC"
			exit 
		fi
	}
	output{
		Array[File] QCedPaired = ['QC/QC.1.trimmed.fastq','QC/QC.2.trimmed.fastq']
		File QCedSingle = "QC/QC.unpaired.trimmed.fastq"
		File QCstat = "QC/QC.stats.txt"
		File QCstatPDF = "QC/QC_qc_report.pdf"
	}
	runtime{ mem: "20GB"
                cpu: cpu
             jobname: "QC_" + projectName
                 }

}

task run_assembly{
	String assembler
	Int cpu
 	String opts
 	Array[File] PairedReads
	File? SingleRead
	Int mem = 100
 	Int minLen = 500
	String outdir
	String projectName
	Int pairedNumber = length(PairedReads)
	command {
		#source activate && conda activate /scratch-218819/apps/Anaconda3/envs/metawrap
		#mkdir -p ${outdir}
		if [ ${pairedNumber} -eq 2 ]; then
			shifter --image=docker:bioedge/nmdc_mags:withchkmdb metawrap assembly -1 ${sep=" -2 " PairedReads} -l ${minLen} -o assembly -m ${mem}  ${"--" + assembler} -t ${cpu} 
		else
			# presume interleaved format
			mkdir -p assembly
			seqtk seq -1 ${PairedReads[0]} > assembly/read_1.fastq
			seqtk seq -2 ${PairedReads[0]} > assembly/read_2.fastq
			shifter --image=docker:bioedge/nmdc_mags:withchkmdb metawrap assembly -1 assembly/read_1.fastq -2 assembly/read_2.fastq -l ${minLen} -o assembly -m ${mem}  ${"--" + assembler} -t ${cpu}
		fi
		## Not support single end reads
		#if [ -f "${SingleRead}" ]; then
		#	metawrap assembly -1 ${PairedReads[0]} -2 ${PairedReads[1]} ${"--" + assembler} -t ${cpu} -o assembly -m ${mem} -l ${minLen}
		#fi
	}


	output {
		File contig = 'assembly/final_assembly.fasta'
		File quastPDf = 'assembly/QUAST_out/report.pdf'
		File quastHTML = 'assembly/assembly_report.html'
	}
        runtime{ mem: mem + "GB"
                 cpu: cpu
		jobname: "ASM_"+ projectName
                }
}


task make_output{
	String outdir
	String qc_stat
	String contig
	String projectName
	command{
		mkdir -p ${outdir}
		QCpath=`dirname ${qc_stat}`
		AssemblyPath=`dirname ${contig}`
		mv -f $QCpath ${outdir}/
		mv -f $AssemblyPath ${outdir}/
		chmod 764 -R ${outdir}
	}
        runtime{ mem: "1GB"
                 cpu: 1
		jobname: "output_"+ projectName
                }
}

