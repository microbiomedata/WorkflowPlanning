task BuildHisat2{
	Int cpu
	File ref_genome
	String ref_name = basename(ref_genome, ".fna")

	meta {
		description: "build reference index files for hisat2"
	}

	command {
		hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
		touch ${ref_name}
	}

	output {
		Array[File] hs = [ref_name + ".1.ht2", ref_name + ".2.ht2",
						ref_name + ".3.ht2",
					  	ref_name + ".4.ht2",
					  	ref_name + ".5.ht2",
					  	ref_name + ".6.ht2",
					  	ref_name + ".7.ht2",
					  	ref_name + ".8.ht2"]
		File db = ref_name
	}
}


task shift_BuildHisat2{
	Int cpu
	File ref_genome
	String container
	String ref_name = basename(ref_genome, ".fna")

	meta {
		description: "build reference index files for hisat2"
	}

	command {
		shifter --image=${container} hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
		touch ${ref_name}
	}

	output {
			Array[File] hs = [ref_name + ".1.ht2", ref_name + ".2.ht2",
						ref_name + ".3.ht2",
					  	ref_name + ".4.ht2",
					  	ref_name + ".5.ht2",
					  	ref_name + ".6.ht2",
					  	ref_name + ".7.ht2",
					  	ref_name + ".8.ht2"]
		File db = ref_name
	}

	runtime {
		poolname: "aim2_metaT"
		cluster: "cori"
		time: "01:00:00"
		cpu: cpu
		mem: "115GB"
		node: 1
		nwpn: 2
	}
}

task dock_BuildHisat2{
	Int cpu
	File ref_genome
	String ref_name = basename(ref_genome, ".fna")

	meta {
		description: "build reference index files for hisat2"
	}

	command {
		hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
		touch ${ref_name}
		
	}
	output {
		Array[File] hs = [ref_name + ".1.ht2", ref_name + ".2.ht2",
						ref_name + ".3.ht2",
					  	ref_name + ".4.ht2",
					  	ref_name + ".5.ht2",
					  	ref_name + ".6.ht2",
					  	ref_name + ".7.ht2",
					  	ref_name + ".8.ht2"]
		File db = ref_name
	}
	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}