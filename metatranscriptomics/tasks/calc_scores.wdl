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
