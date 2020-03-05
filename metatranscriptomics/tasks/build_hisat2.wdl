task BuildHisat2{
	Int cpu
	File ref_genome
	String ref_name = basename(ref_genome, ".fna")
	String hisat2_index_name = "${ref_name}.tar.gz"

	meta {
		description: "build reference index files for hisat2"
	}

	command {
		hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
		mkdir ${ref_name}
		mv ./*.ht2 ${ref_name}
		tar -zcvf ${hisat2_index_name} ${ref_name}
	}

	output {
	File hisat2_index = hisat2_index_name
	}
}


task shift_BuildHisat2{
	Int cpu
	File ref_genome
	String ref_name = basename(ref_genome, ".fna")
	String hisat2_index_name = "${ref_name}.tar.gz"

	meta {
		description: "build reference index files for hisat2"
	}

	command {
		shifter --image=migun/nmdc_metat:latest hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
		mkdir ${ref_name}
		mv ./*.ht2 ${ref_name}
		tar -zcvf ${hisat2_index_name} ${ref_name}
	}

	output {
	File hisat2_index = hisat2_index_name
	}
}

task dock_BuildHisat2{
	Int cpu
	File ref_genome
	String ref_name = basename(ref_genome, ".fna")
	String hisat2_index_name = "${ref_name}.tar.gz"

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