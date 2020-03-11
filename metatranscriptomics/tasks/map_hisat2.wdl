task mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	Array[File] hisat2_ref
	File db

	command {
		hisat2 -p ${cpu} -x ${db} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${projectName}.bam
	}

	output{
		File map_bam = "${projectName}.bam"
	}
}


task shift_mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	Array[File] hisat2_ref
	File db
	String container

	command <<<
		shifter --image=${container} -- hisat2 -p ${cpu} -x ${db} -1 ${PairedReads[0]} -2 ${PairedReads[1]} > ${projectName}.sam
		shifter --image=${container} -- samtools view -Sbo ${projectName}.sam -o ${projectName}.bam
	>>>

	output{
		File map_bam = "${projectName}.bam"
	}
}

task dock_mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	Array[File] hisat2_ref
	File db

	command {
		hisat2 -p ${cpu} -x ${db} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${projectName}.bam
	}

	output{
		File map_bam = "${projectName}.bam"
	}
	
	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}