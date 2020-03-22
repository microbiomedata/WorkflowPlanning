task CalScores{
	File edgeR="scripts/edgeR.R"
	Int cpu
	String projectName
	File fc_file

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		mv ${edgeR} script.R
		Rscript script.R -r ${fc_file} -n CDS -o ${projectName}_sc_tbl.tsv -s ${projectName}
	}

	output {
	File sc_tbl = "${projectName}_sc_tbl.tsv"
	}
}



task shift_CalScores{
	Int cpu
	String projectName
	File fc_file
	String container

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		shifter --image=${container} edgeR.R -r ${fc_file} -n CDS -o ${projectName}_sc_tbl.tsv -s ${projectName}
	}

	runtime {
		poolname: "aim2_metaT"
		cluster: "cori"
		time: "01:00:00"
		cpu: cpu
		mem: "10GB"
		node: 1
		nwpn: 1
	}

	output {
	File sc_tbl = "${projectName}_sc_tbl.tsv"
	}
}


task dock_CalScores{
	Int cpu
	String projectName
	File fc_file

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		edgeR.R -r ${fc_file} -n CDS -o ${projectName}_sc_tbl.tsv -s ${projectName}
	}

	output {
	File sc_tbl = "${projectName}_sc_tbl.tsv"
	}

	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}
