task mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	String hisat2_ref
	String ref_genome
	String ref_name = basename(ref_genome, ".fna")

		# shifter --image=docker:migun/piret hisat2 -p ${cpu} -x ${index} -1 PairedReads[0] -2 PairedReads[1] -S ${outsam}
	command {
		tar --no-same-owner -xvf "${hisat2_ref}"
		hisat2 -p ${cpu} -x ${ref_name}/${ref_name} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${projectName}.bam
	}

	output{
		File map_bam = "${projectName}.bam"
	}
}


task shift_mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	String hisat2_ref
	String ref_genome
	String ref_name = basename(ref_genome, ".fna")

	command {
		tar --no-same-owner -xvf "${hisat2_ref}"
		shifter --image=docker:migun/nmdc_metat hisat2 -p ${cpu} -x ${ref_name}/${ref_name} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${projectName}.bam
	}

	output{
		File map_bam = "${projectName}.bam"
	}
}

task dock_mapping{
	Int cpu
	Array[File] PairedReads
	String projectName
	String hisat2_ref
	String ref_genome
	String ref_name = basename(ref_genome, ".fna")

	command {
		tar --no-same-owner -xvf "${hisat2_ref}"
		hisat2 -p ${cpu} -x ${ref_name}/${ref_name} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${projectName}.bam
	}

	output{
		File map_bam = "${projectName}.bam"
	}
	
	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}