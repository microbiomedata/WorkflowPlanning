task qc{
	Array[File] PairedReads
	File? QCSingleRead
	String opts
	Int cpu
	String projectName
	String outdir

	# need to add shifter command here when running it in NERSC
	command {
		FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
	}

	output{
		Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',outdir+'/QC.2.trimmed.fastq']
		File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
		File QCstat = outdir + "/QC.stats.txt"
		File QCstatPDF = outdir + "/QC_qc_report.pdf"
	}

}

task shift_qc{
	Array[File] PairedReads
	File? QCSingleRead
	String opts
	Int cpu
	String projectName
	String outdir

	# need to add shifter command here when running it in NERSC
	command {
		shifter --image=migun/nmdc_metat:latest FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
	}

	output{
		Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',outdir+'/QC.2.trimmed.fastq']
		File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
		File QCstat = outdir + "/QC.stats.txt"
		File QCstatPDF = outdir + "/QC_qc_report.pdf"
	}

}

task dock_qc{
	Array[File] PairedReads
	File? QCSingleRead
	String opts
	Int cpu
	String projectName
	String outdir

	# need to add shifter command here when running it in NERSC
	command {
		FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
	}

	output{
		Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',outdir+'/QC.2.trimmed.fastq']
		File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
		File QCstat = outdir + "/QC.stats.txt"
		File QCstatPDF = outdir + "/QC_qc_report.pdf"
	}

	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}