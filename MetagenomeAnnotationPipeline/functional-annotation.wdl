workflow f_annotate {

  String  imgap_project_id
  String  imgap_project_type
  Int     additional_threads
  File    input_fasta
  Boolean ko_ec_execute
  String  ko_ec_img_nr_db
  String    ko_ec_md5_mapping
  String    ko_ec_taxon_to_phylo_mapping
  String  lastal_bin
  String  selector_bin
  Boolean smart_execute
  Int?    par_hmm_inst
  Int?    approx_num_proteins
  String    smart_db
  String  hmmsearch_bin
  String  frag_hits_filter_bin
  Boolean cog_execute
  String    cog_db
  Boolean tigrfam_execute
  String    tigrfam_db
  String  hit_selector_bin
  Boolean superfam_execute
  String    superfam_db
  Boolean pfam_execute
  String    pfam_db
  String    pfam_claninfo_tsv
  String  pfam_clan_filter
  Boolean cath_funfam_execute
  String    cath_funfam_db
  Boolean signalp_execute
  String  signalp_gram_stain
  String  signalp_bin
  Boolean tmhmm_execute
  String  tmhmm_model
  String  tmhmm_decode
  String  tmhmm_decode_parser
  File    sa_gff
  String  product_assign_bin
  String  product_names_mapping_dir

  if(ko_ec_execute) {
    call ko_ec {
      input:
        project_id = imgap_project_id,
        project_type = imgap_project_type,
        input_fasta = input_fasta,
        threads = additional_threads,
        nr_db = ko_ec_img_nr_db,
        md5 = ko_ec_md5_mapping,
        phylo = ko_ec_taxon_to_phylo_mapping,
        lastal = lastal_bin,
        selector = selector_bin
    }
  }
  if(smart_execute) {
    call smart {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        smart_db = smart_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin
    }
  }
  if(cog_execute) {
    call cog {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        cog_db = cog_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin
    }
  }
  if(tigrfam_execute) {
    call tigrfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        tigrfam_db = tigrfam_db,
        hmmsearch = hmmsearch_bin,
        hit_selector = hit_selector_bin
    }
  }
  if(superfam_execute) {
    call superfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        superfam_db = superfam_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin
    }
  }
  if(pfam_execute) {
    call pfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        pfam_db = pfam_db,
        pfam_claninfo_tsv = pfam_claninfo_tsv,
        pfam_clan_filter = pfam_clan_filter,
        hmmsearch = hmmsearch_bin
    }
  }
  if(cath_funfam_execute) {
    call cath_funfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        cath_funfam_db = cath_funfam_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin
    }
  }
  if(imgap_project_type == "isolate" && signalp_execute) {
    call signalp {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        gram_stain = signalp_gram_stain,
        signalp = signalp_bin
    }
  }
  if(imgap_project_type == "isolate" && tmhmm_execute) {
    call tmhmm {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        model = tmhmm_model,
        decode = tmhmm_decode,
        decode_parser = tmhmm_decode_parser
    }
  }
  call product_name {
    input:
      project_id = imgap_project_id,
      sa_gff = sa_gff,
      product_assign = product_assign_bin,
      map_dir = product_names_mapping_dir,
      ko_ec_gff = ko_ec.gff,
      smart_gff = smart.gff,
      cog_gff = cog.gff,
      tigrfam_gff = tigrfam.gff,
      supfam_gff = superfam.gff,
      pfam_gff = pfam.gff,
      cath_funfam_gff = cath_funfam.gff,
      signalp_gff = signalp.gff,
      tmhmm_gff = tmhmm.gff
  }
}

task ko_ec {

  String project_id
  String project_type
  Int    threads = 2
  File   input_fasta
  String nr_db
  String   md5
  String   phylo
  Int    top_hits = 5
  Int    min_ko_hits = 2
  Float  aln_length_ratio = 0.7
  String lastal
  String selector

  command {
    ${lastal} -f blasttab+ -P ${threads} ${nr_db} ${input_fasta} 1> ${project_id}_proteins.img_nr.last.blasttab
    ${selector} -l ${aln_length_ratio} -m ${min_ko_hits} -n ${top_hits} \
                ${project_type} ${md5} ${phylo} \
                ${project_id}_ko.tsv ${project_id}_ec.tsv \
                ${project_id}_gene_phylogeny.tsv ${project_id}_ko_ec.gff \
                < ${project_id}_proteins.img_nr.last.blasttab
  }

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File last_blasttab = "${project_id}_proteins.img_nr.last.blasttab"
    File ko_tsv = "${project_id}_ko.tsv"
    File ec_tsv = "${project_id}_ec.tsv"
    File phylo_tsv = "${project_id}_gene_phylogeny.tsv"
    File gff = "${project_id}_ko_ec.gff"
  }
}

task smart {
  
  String project_id
  File   input_fasta
  String   smart_db
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
    then
        hmmsearch_threads=$(echo ${threads} / ${par_hmm_inst} | bc)
        printf "$(date +%F_%T) - Splitting up proteins fasta into ${par_hmm_inst} "
        printf "pieces now and then run hmmsearch on them separately with ${threads} "
        printf "threads each against the Smart db...\n"
        tmp_dir=.
        filesize=$(ls -l ${input_fasta} | awk '{print $5}')
        blocksize=$((($filesize / ${par_hmm_inst}) + 20000))

        hmmsearch_base_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
		# TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
        fi
        hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu ${threads}"
        # Use parallel to split up the input and
        # run hmmsearch in parallel on those splits
#        cat ${input_fasta} | parallel --pipe --recstart '>' \
#                             --blocksize $blocksize \
#                             cat > $tmp_dir/tmp.$$.split.faa; \
#                             $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.smart.$$.domtblout \
#                             ${smart_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		# TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
		$hmmsearch_base_cmd --domtblout $tmp_dir/tmp.smart.$$.domtblout ${smart_db} ${input_fasta} 1> /dev/null

        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "GNU parallel run failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Concatenating split result files now..."
        cat $tmp_dir/tmp.smart.* > ${project_id}_proteins.smart.domtblout
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "Concatenating split outputs failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Deleting tmp files now..."
        rm $tmp_dir/tmp.*
    else
        echo "$(date +%F_%T) - Calling hmmsearch against the SMART db now..."
        hmmsearch_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
        fi
        hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.smart.domtblout "
        hmmsearch_cmd="$hmmsearch_cmd ${smart_db} ${input_fasta} 1> /dev/null"
        $hmmsearch_cmd
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
            exit $exit_code
        fi
    fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.smart.domtblout | \
    awk '{print $1,$3,$4,$5,$6,$7,$8,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k7,7nr -k6,6n | \
    ${frag_hits_filter} -a ${aln_length_ratio} -o ${max_overlap_ratio} \
                        "$tool_and_version" > ${project_id}_smart.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_smart.gff"
    File domtblout = "${project_id}_proteins.smart.domtblout"
  }
}

task cog {
  
  String project_id
  File   input_fasta
  String   cog_db
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
    then
        number_of_parallel_instances=4
        hmmsearch_threads=$(echo ${threads} / $number_of_parallel_instances | bc)
        printf "$(date +%F_%T) - Splitting up proteins fasta into $number_of_parallel_instances "
        printf "pieces now and then run hmmsearch on them separately with $hmmsearch_threads "
        printf "threads each against the COG db...\n"
        tmp_dir=.
        filesize=$(ls -l ${input_fasta} | awk '{print $5}')
        blocksize=$((($filesize / $number_of_parallel_instances) + 30000))

        hmmsearch_base_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
		# TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
        fi  
        hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu $hmmsearch_threads "
        # Use parallel to split up the input and
        # run hmmsearch in parallel on those splits
		
#        cat ${input_fasta} | parallel --pipe --recstart '>' \
#                             --blocksize $blocksize \
#                             cat > $tmp_dir/tmp.$$.split.faa;  \
#                             $hmmsearch_base_cmd \
#                             --domtblout $tmp_dir/tmp.cog.$$.domtblout \
#                             ${cog_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		# TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
        $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.cog.$$.domtblout ${cog_db} ${input_fasta} 1> /dev/null

        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "GNU parallel run failed! Aborting!" >&2
            exit $exit_code
        fi
        echo "$(date +%F_%T) - Concatenating split result files now..."
        cat $tmp_dir/tmp.cog.* > ${project_id}_proteins.cog.domtblout
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "Concatenating split outputs failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Deleting tmp files now..."
        rm $tmp_dir/tmp.*
    else
      echo "$(date +%F_%T) - Calling hmmsearch to predict COGs now..."
      hmmsearch_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
      if [[ ${approx_num_proteins} -gt 0 ]]
      then
          hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
      fi
      hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.cog.domtblout "
      hmmsearch_cmd="$hmmsearch_cmd ${cog_db} ${input_fasta} 1> /dev/null"
      $hmmsearch_cmd
      exit_code=$?
      if [[ $exit_code -ne 0 ]]
      then
          echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
          exit $exit_code
      fi
    fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.cog.domtblout | \
    awk '{print $1,$3,$4,$5,$6,$7,$8,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k7,7nr -k6,6n | \
    ${frag_hits_filter} -a ${aln_length_ratio} -o ${max_overlap_ratio} \
                        "$tool_and_version" > ${project_id}_cog.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_cog.gff"
	File domtblout = "${project_id}_proteins.cog.domtblout"
  }
}

task tigrfam {
  
  String project_id
  File   input_fasta
  String   tigrfam_db
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String hit_selector

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
      then
          hmmsearch_threads=$(echo ${threads} / ${par_hmm_inst} | bc)
          printf "$(date +%F_%T) - Splitting up proteins fasta into ${par_hmm_inst} "
          printf "pieces now and then run hmmsearch on them separately with ${threads} "
          printf "threads each against the TIGRFAM db...\n"
          tmp_dir=.
          filesize=$(ls -l ${input_fasta} | awk '{print $5}')
          blocksize=$((($filesize / ${par_hmm_inst}) + 20000))

          hmmsearch_base_cmd="${hmmsearch} --notextw --cut_nc"
		  #TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
          #if [[ ${par_hmm_inst} -gt 0 ]]
          #then
          #    hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
          #fi
          hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu $hmmsearch_threads "
          # Use parallel to split up the input and
          # run hmmsearch in parallel on those splits
#          cat ${input_fasta} | parallel --pipe --recstart '>' \
#                               --blocksize $blocksize \
#                               cat > $tmp_dir/tmp.$$.split.faa;  \
#                               $hmmsearch_base_cmd \
#                               --domtblout $tmp_dir/tmp.tigrfam.$$.domtblout \
#                                ${tigrfam_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		  # TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
          $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.tigrfam.$$.domtblout ${tigrfam_db} ${input_fasta} 1> /dev/null

          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "GNU parallel run failed! Aborting!" >&2
              exit $exit_code
          fi

          echo "$(date +%F_%T) - Concatenating split result files now..."
          cat $tmp_dir/tmp.tigrfam.* > ${project_id}_proteins.tigrfam.domtblout
          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "Concatenating split outputs failed! Aborting!" >&2
              exit $exit_code
          fi

          echo "$(date +%F_%T) - Deleting tmp files now..."
          rm $tmp_dir/tmp.*
      else
          echo "$(date +%F_%T) - Calling hmmsearch to predict TIGRFAMs now..."
          hmmsearch_cmd="${hmmsearch} --notextw --cut_nc"
          if [[ ${approx_num_proteins} -gt 0 ]]
          then
              hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
          fi
          hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.tigrfam.domtblout "
          hmmsearch_cmd="$hmmsearch_cmd ${tigrfam_db} ${input_fasta} 1> /dev/null"
          $hmmsearch_cmd
          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
              exit $exit_code
          fi
      fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.tigrfam.domtblout | \
    awk '{print $1,$3,$4,$6,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k6,6nr -k5,5n | \
    ${hit_selector} -a ${aln_length_ratio} -o ${max_overlap_ratio} \
                    "$tool_and_version" > ${project_id}_tigrfam.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_tigrfam.gff"
	File domtblout = "${project_id}_proteins.tigrfam.domtblout"
  }
}

task superfam {

  String project_id
  File   input_fasta
  String   superfam_db
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
      then
		  # from marcel's original code
	      #hmmsearch_threads=$(echo $number_of_additional_threads / $number_of_parallel_hmmsearch_instances | bc)
          hmmsearch_threads=$(echo ${threads} / ${par_hmm_inst} | bc)
          printf "$(date +%F_%T) - Splitting up proteins fasta into ${par_hmm_inst} "
          printf "pieces now and then run hmmsearch on them separately with $hmmsearch_threads "
          printf "threads each against the SuperFamily db...\n"
          tmp_dir=.
          filesize=$(ls -l ${input_fasta} | awk '{print $5}')
          blocksize=$((($filesize / ${par_hmm_inst}) + 20000))

          hmmsearch_base_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
		  # TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
          if [[ ${approx_num_proteins} -gt 0 ]]
          then
              hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
          fi  
          hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu $hmmsearch_threads "
          # Use parallel to split up the input and
          # run hmmsearch in parallel on those splits
#          cat ${input_fasta} |  parallel --pipe --recstart '>' \
#                               --blocksize $blocksize \
#                               cat > $tmp_dir/tmp.$$.split.faa;  \
#                               $hmmsearch_base_cmd \
#                               --domtblout $tmp_dir/tmp.supfam.$$.domtblout \
#                               ${superfam_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		  # TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
          $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.supfam.$$.domtblout ${superfam_db} ${input_fasta} 1> /dev/null

          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "GNU parallel run failed! Aborting!" >&2
              exit $exit_code
          fi  

          echo "$(date +%F_%T) - Concatenating split result files now..."
          cat $tmp_dir/tmp.supfam.* > ${project_id}_proteins.supfam.domtblout
          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "Concatenating split outputs failed! Aborting!" >&2
              exit $exit_code
          fi
      else
          echo "$(date +%F_%T) - Calling hmmsearch against the SuperFamily db now..."
          hmmsearch_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
          if [[ ${approx_num_proteins} -gt 0 ]]
          then
              hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
          fi  
          hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.supfam.domtblout "
          hmmsearch_cmd="$hmmsearch_cmd ${superfam_db} ${input_fasta} 1> /dev/null"
          $hmmsearch_cmd
          exit_code=$?
          if [[ $exit_code -ne 0 ]]
          then
              echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
              exit $exit_code
          fi  
      fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.supfam.domtblout | \
    awk '{print $1,$3,$4,$5,$6,$7,$8,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k7,7nr -k6,6n | \
    ${frag_hits_filter} -a ${aln_length_ratio} -o ${max_overlap_ratio} \
                        "$tool_and_version" > ${project_id}_supfam.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_supfam.gff"
	File domtblout = "${project_id}_proteins.supfam.domtblout"
  }
}

task pfam {
  
  String project_id
  File   input_fasta
  String   pfam_db
  String   pfam_claninfo_tsv
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  String hmmsearch
  String pfam_clan_filter

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
    then
        hmmsearch_threads=$(echo ${threads} / ${par_hmm_inst} | bc)
        printf "$(date +%F_%T) - Splitting up proteins fasta into ${par_hmm_inst} "
        printf "pieces now and then run hmmsearch on them separately with $hmmsearch_threads "
        printf "threads each against the Pfam db...\n"
        tmp_dir=.
        filesize=$(ls -l ${input_fasta} | awk '{print $5}')
        blocksize=$((($filesize / ${par_hmm_inst}) + 20000))

        hmmsearch_base_cmd="${hmmsearch} --notextw --cut_tc"
		# TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
        fi  
        hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu $hmmsearch_threads "
        # Use parallel to split up the input and
        # run hmmsearch in parallel on those splits
#        cat ${input_fasta} | parallel --pipe --recstart '>' \
#                             --blocksize $blocksize \
#                             cat > $tmp_dir/tmp.$$.split.faa;  \
#                             $hmmsearch_base_cmd \
#                             --domtblout $tmp_dir/tmp.pfam.$$.domtblout \
#                             ${pfam_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		# TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
        $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.pfam.$$.domtblout ${pfam_db} ${input_fasta} 1> /dev/null

        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "GNU parallel run failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Concatenating split result files now..."
        cat $tmp_dir/tmp.pfam.* > ${project_id}_proteins.pfam.domtblout
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "Concatenating split outputs failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Deleting tmp files now..."
        rm $tmp_dir/tmp.*
    else
        echo "$(date +%F_%T) - Calling hmmsearch to predict Pfams now..."
        hmmsearch_cmd="${hmmsearch} --notextw --cut_tc"
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
        fi
        hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.pfam.domtblout "
        hmmsearch_cmd="$hmmsearch_cmd ${pfam_db} ${input_fasta} 1> /dev/null"
        $hmmsearch_cmd
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
            exit $exit_code
        fi
    fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.pfam.domtblout | \
    awk '{print $1,$3,$4,$6,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k6,6nr -k5,5n | \
    ${pfam_clan_filter} "$tool_and_version" ${pfam_claninfo_tsv} > ${project_id}_pfam.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_pfam.gff"
	File domtblout = "${project_id}_proteins.pfam.domtblout"
  }
}

task cath_funfam {
  
  String project_id
  File   input_fasta
  String   cath_funfam_db
  Int    threads = 2
  Int    par_hmm_inst = 1
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter

  command <<<
    if [[ ${threads} -gt ${par_hmm_inst} ]]
    then
        hmmsearch_threads=$(echo ${threads} / ${par_hmm_inst} | bc)
        printf "$(date +%F_%T) - Splitting up proteins fasta into ${par_hmm_inst} "
        printf "pieces now and then run hmmsearch on them separately with $hmmsearch_threads "
        printf "threads each against the Cath-FunFam db...\n"
        tmp_dir=.
        filesize=$(ls -l ${input_fasta} | awk '{print $5}')
        blocksize=$((($filesize / ${par_hmm_inst}) + 20000))

        hmmsearch_base_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
		# TODO: jeff use default -Z setting for hmmscan until approx_num_proteins gets assigned by marcel
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_base_cmd="$hmmsearch_base_cmd -Z ${approx_num_proteins}"
        fi
        hmmsearch_base_cmd="$hmmsearch_base_cmd --cpu $hmmsearch_threads "
        # Use parallel to split up the input and
        # run hmmsearch in parallel on those splits
#        cat ${input_fasta} | parallel --pipe --recstart '>' \
#                             --blocksize $blocksize \
#                             cat > $tmp_dir/tmp.$$.split.faa;  \
#                             $hmmsearch_base_cmd \
#                             --domtblout $tmp_dir/tmp.cath_funfam.$$.domtblout \
#                             ${cath_funfam_db} $tmp_dir/tmp.$$.split.faa 1> /dev/null;

		# TODO: jeff removed parallel command since I couldn't get it working when using the obligate shifter version
        $hmmsearch_base_cmd --domtblout $tmp_dir/tmp.cath_funfam.$$.domtblout ${cath_funfam_db} ${input_fasta} 1> /dev/null

        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "GNU parallel run failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Concatenating split result files now..."
        cat $tmp_dir/tmp.cath_funfam.* > ${project_id}_proteins.cath_funfam.domtblout
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "Concatenating split outputs failed! Aborting!" >&2
            exit $exit_code
        fi

        echo "$(date +%F_%T) - Deleting tmp files now..."
        rm $tmp_dir/tmp.*
    else
        echo "$(date +%F_%T) - Calling hmmsearch to predict Cath-FunFams now..."
        hmmsearch_cmd="${hmmsearch} --notextw --domE ${min_domain_eval_cutoff}"
        if [[ ${approx_num_proteins} -gt 0 ]]
        then
            hmmsearch_cmd="$hmmsearch_cmd -Z ${approx_num_proteins}"
        fi
        hmmsearch_cmd="$hmmsearch_cmd --domtblout ${project_id}_proteins.cath_funfam.domtblout "
        hmmsearch_cmd="$hmmsearch_cmd ${cath_funfam_db} ${input_fasta} 1> /dev/null"
        $hmmsearch_cmd
        exit_code=$?
        if [[ $exit_code -ne 0 ]]
        then
            echo "$(date +%F_%T) - hmmsearch failed! Aborting!" >&2
            exit $exit_code
        fi
    fi

    tool_and_version=$(${hmmsearch} -h | grep HMMER | sed -e 's/.*#\(.*\)\;.*/\1/')
    grep -v '^#' ${project_id}_proteins.cath_funfam.domtblout | \
    awk '{print $1,$3,$4,$5,$6,$7,$8,$13,$14,$16,$17,$20,$21}' | \
    sort -k1,1 -k7,7nr -k6,6n | \
    ${frag_hits_filter} -a ${aln_length_ratio} -o ${max_overlap_ratio} \
                        "$tool_and_version" > ${project_id}_cath_funfam.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_cath_funfam.gff"
	File domtblout = "${project_id}_proteins.cath_funfam.domtblout"
  }
}

task signalp {
  
  String project_id
  File   input_fasta
  String gram_stain
  String signalp

  command <<<
    signalp_version=$(${signalp} -V)
    ${signalp} -t ${gram_stain} -f short ${input_fasta} | \
    grep -v '^#' | \
    awk -v sv="$signalp_version" -v ot="${gram_stain}" \
        '$10 == "Y" {print $1"\t"sv"\tcleavage_site\t"$3-1"\t"$3"\t"$2\
        "\t.\t.\tD-score="$9";network="$12";organism_type="ot}' > ${project_id}_cleavage_sites.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_cleavage_sites.gff"
  }
}

task tmhmm {
  
  String project_id
  File   input_fasta
  String model
  String decode
  String decode_parser

  command <<<
    tool_and_version=$(${decode} -v 2>&1 | head -1)
    background="0.081 0.015 0.054 0.061 0.040 0.068 0.022 0.057 0.056 0.093 0.025"
    background="$background 0.045 0.049 0.039 0.057 0.068 0.058 0.067 0.013 0.032"
    sed 's/\*/X/g' ${input_fasta} | \
    ${decode} -N 1 -background $background -PrintNumbers \
    ${model} 2> /dev/null | ${decode_parser} "$tool_and_version" > ${project_id}_tmh.gff
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_tmh.gff"
  }
}

task product_name {
  
  String project_id
  File   sa_gff
  String product_assign
  String map_dir
  File?  ko_ec_gff
  File?  smart_gff
  File?  cog_gff
  File?  tigrfam_gff
  File?  supfam_gff
  File?  pfam_gff
  File?  cath_funfam_gff
  File?  signalp_gff
  File?  tmhmm_gff

  command {
    ${product_assign} ${"-k " + ko_ec_gff} ${"-s " + smart_gff} ${"-c " + cog_gff} \
                      ${"-t " + tigrfam_gff} ${"-u " + supfam_gff} ${"-p " + pfam_gff} \
                      ${"-f " + cath_funfam_gff} ${"-e " + signalp_gff} ${"-r " + tmhmm_gff} \
                      ${map_dir} ${sa_gff}
    mv ../inputs/*/*.gff .
  }

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "small"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_functional_annotation.gff"
  }
}
