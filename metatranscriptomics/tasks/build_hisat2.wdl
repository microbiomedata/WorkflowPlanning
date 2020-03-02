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
		mkdir ${ref_name}
		mv ./*.ht2 ${ref_name}
		tar -zcvf ${hisat2_index_name} ${ref_name}
	}

	output {
	File hisat2_index = hisat2_index_name
	}
	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}