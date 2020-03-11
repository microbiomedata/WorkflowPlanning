task featurecount{
	Int cpu
	String projectName
	File ref_gff
	File bam_file

	command {
		featureCounts -a ${ref_gff} -B -p -P -C -g ID -t CDS -T ${cpu} -o ${projectName}.count ${bam_file} 
	}

	output{
		File ct_tbl = "${projectName}.count"
	}
}


task shift_featurecount{
	Int cpu
	String projectName
	File ref_gff
	File bam_file
	String container

	command {
		shifter --image=${container} featureCounts -a ${ref_gff} -B -p -P -C -g ID -t CDS -T ${cpu} -o ${projectName}.count ${bam_file} 
	}

	output{
		File ct_tbl = "${projectName}.count"
	}
}


task dock_featurecount{
	Int cpu
	String projectName
	File ref_gff
	File bam_file

	command {
		featureCounts -a ${ref_gff} -B -p -P -C -g ID -t CDS -T ${cpu} -o ${projectName}.count ${bam_file} 
	}

	output{
		File ct_tbl = "${projectName}.count"
	}

	runtime {
		docker: 'migun/nmdc_metat:latest'
	}

}