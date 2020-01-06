task profilerGottcha2 {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    String? RELABD_COL = "ROLLUP_DOC"
    Int? CPU = 4

    command <<<
        mkdir -p ${OUTPATH}

        gottcha2.py -r ${RELABD_COL} \
                    -i ${sep=' ' READS} \
                    -t ${CPU} \
                    -o ${OUTPATH} \
                    -p ${PREFIX} \
                    --database ${DB}
        
        awk -F"\t" '{if($NF=="" || $NF=="NOTE"){print $_}}' ${OUTPATH}/${PREFIX}.full.tsv | cut -f -10 > ${OUTPATH}/${PREFIX}.summary.tsv
        awk -F"\t" '{if(NR==1){out=$1"\t"$2"\tROLLUP\tASSIGNED"; { for(i=3;i<=NF;i++){out=out"\t"$i}}; print out;}}' ${OUTPATH}/${PREFIX}.summary.tsv > ${OUTPATH}/${PREFIX}.out.list
        awk -F"\t" '{if(NR>1){out=$1"\t"$2"\t"$4"\t"; { for(i=3;i<=NF;i++){out=out"\t"$i}}; print out;}}' ${OUTPATH}/${PREFIX}.summary.tsv >> ${OUTPATH}/${PREFIX}.out.list
        cp ${OUTPATH}/${PREFIX}.lineage.tsv ${OUTPATH}/${PREFIX}.out.tab_tree
        ktImportText ${OUTPATH}/${PREFIX}.out.tab_tree -o ${OUTPATH}/${PREFIX}.krona.html
    >>>
    output {
        File orig_out_tsv = "${OUTPATH}/${PREFIX}.summary.tsv"
        File orig_full_tsv = "${OUTPATH}/${PREFIX}.full.tsv"
        File orig_log = "${OUTPATH}/${PREFIX}.gottcha_species.log"
        File krona_html = "${OUTPATH}/${PREFIX}.krona.html"
    }
    runtime {
        memory: "30GB"
        cpu: CPU
        docker: "poeli/nmdc_taxa_profilers:latest"
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

task profilerCentrifuge {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    Int? CPU = 4

    command <<<
        mkdir -p ${OUTPATH}

        centrifuge -x ${DB} \
                   -p ${CPU} \
                   -U ${sep=',' READS} \
                   -S ${OUTPATH}/${PREFIX}.classification.csv \
                   --report-file ${OUTPATH}/${PREFIX}.report.csv
        
        centrifuge-kreport -x ${DB} ${OUTPATH}/${PREFIX}.classification.csv > ${OUTPATH}/${PREFIX}.kreport.csv
        ktImportTaxonomy -m 3 -t 5 ${OUTPATH}/${PREFIX}.kreport.csv -o ${OUTPATH}/${PREFIX}.krona.html
    >>>
    output {
        File orig_out_tsv = "${OUTPATH}/${PREFIX}.classification.csv"
        File orig_rep_tsv = "${OUTPATH}/${PREFIX}.report.csv"
        File krona_html = "${OUTPATH}/${PREFIX}.krona.html"
    }
    runtime {
        memory: "30GB"
        cpu: CPU
        docker: "poeli/nmdc_taxa_profilers:latest"
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

task profilerKraken2 {
    Array[File] READS
    String DB
    String OUTPATH
    String PREFIX
    Boolean? PAIRED = false
    Int? CPU = 4

    command <<<
        mkdir -p ${OUTPATH}
        
        kraken2 ${true="--paired" false='' PAIRED} \
                --threads ${CPU} \
                --db ${DB} \
                --output ${OUTPATH}/${PREFIX}.classification.csv \
                --report ${OUTPATH}/${PREFIX}.report.csv \
                ${sep=' ' READS}

        ktImportTaxonomy -m 3 -t 5 ${OUTPATH}/${PREFIX}.report.csv -o ${OUTPATH}/${PREFIX}.krona.html
    >>>
    output {
        File orig_out_tsv = "${OUTPATH}/${PREFIX}.classification.csv"
        File orig_rep_tsv = "${OUTPATH}/${PREFIX}.report.csv"
        File krona_html = "${OUTPATH}/${PREFIX}.krona.html"
    }
    runtime {
        memory: "30GB"
        cpu: CPU
        docker: "poeli/nmdc_taxa_profilers:latest"
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}

