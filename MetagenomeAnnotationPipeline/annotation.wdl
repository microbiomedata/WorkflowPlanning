import "https://portal.nersc.gov/project/m3408/wdl/structural-annotation.wdl" as sa
import "https://portal.nersc.gov/project/m3408/wdl/functional-annotation.wdl" as fa

workflow annotation {

  Int     num_splits
  String  imgap_input_dir
  File    imgap_input_fasta
  String  imgap_project_id
  String  imgap_project_type
  Int     additional_threads
  # structural annotation
  Boolean sa_execute
  Boolean sa_pre_qc_execute
  String  sa_pre_qc_bin
  String  sa_pre_qc_rename
  String  sa_post_qc_bin
  Boolean sa_trnascan_se_execute
  String  sa_trnascan_se_bin
  String  sa_trnascan_pick_and_transform_to_gff_bin
  Boolean sa_rfam_execute
  String  sa_rfam_cmsearch_bin
  String  sa_rfam_clan_filter_bin
  File    sa_rfam_cm
  File    sa_rfam_claninfo_tsv
  File    sa_rfam_feature_lookup_tsv
  Boolean sa_crt_execute
  String  sa_crt_cli_jar
  String  sa_crt_transform_bin
  Boolean sa_prodigal_execute
  String  sa_prodigal_bin
  String  sa_unify_bin
  Boolean sa_genemark_execute
  String  sa_genemark_iso_bin
  String  sa_genemark_meta_bin
  String  sa_genemark_meta_model
  String  sa_gff_merge_bin
  String  sa_fasta_merge_bin
  Boolean sa_gff_and_fasta_stats_execute
  String  sa_gff_and_fasta_stats_bin
  # functional annotation
  Boolean fa_execute
  String  fa_product_names_mapping_dir
  Boolean fa_ko_ec_execute
  String  fa_ko_ec_img_nr_db
  File    fa_ko_ec_md5_mapping
  File    fa_ko_ec_taxon_to_phylo_mapping
  String  fa_lastal_bin
  String  fa_selector_bin
  Boolean fa_cath_funfam_execute
  File    fa_cath_funfam_db
  Boolean fa_pfam_execute
  File    fa_pfam_db
  File    fa_pfam_claninfo_tsv
  String  fa_pfam_clan_filter
  Boolean fa_superfam_excute
  File    fa_superfam_db
  Boolean fa_cog_execute
  File    fa_cog_db
  Boolean fa_tigrfam_execute
  File    fa_tigrfam_db
  String  fa_hit_selector_bin
  Boolean fa_smart_execute
  File    fa_smart_db
  Int?    fa_par_hmm_inst
  Int?    fa_approx_num_proteins
  String  fa_hmmsearch_bin
  String  fa_frag_hits_filter_bin
  Boolean fa_signalp_execute
  String  fa_signalp_bin
  String  fa_signalp_gram_stain
  Boolean fa_tmhmm_execute
  String  fa_tmhmm_model
  String  fa_tmhmm_decode
  String  fa_tmhmm_decode_parser
  String  fa_product_assign_bin

  call setup {
    input:
      n_splits = num_splits,
      dir = imgap_input_dir
  }

  scatter(split in setup.splits) {

    if(sa_execute) {
      call sa.s_annotate {
        input:
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          output_dir = split,
          imgap_input_fasta = "${split}"+"/"+"${imgap_input_fasta}",
          pre_qc_execute = sa_pre_qc_execute,
          pre_qc_bin = sa_pre_qc_bin,
          pre_qc_rename = sa_pre_qc_rename,
          post_qc_bin = sa_post_qc_bin,
          trnascan_se_execute = sa_trnascan_se_execute,
          trnascan_se_bin = sa_trnascan_se_bin,
          trnascan_pick_and_transform_to_gff_bin = sa_trnascan_pick_and_transform_to_gff_bin,
          rfam_execute = sa_rfam_execute,
          rfam_cmsearch_bin = sa_rfam_cmsearch_bin,
          rfam_clan_filter_bin = sa_rfam_clan_filter_bin,
          rfam_cm = sa_rfam_cm,
          rfam_claninfo_tsv = sa_rfam_claninfo_tsv,
          rfam_feature_lookup_tsv = sa_rfam_feature_lookup_tsv,
          crt_execute = sa_crt_execute,
          crt_cli_jar = sa_crt_cli_jar,
          crt_transform_bin = sa_crt_transform_bin,
          prodigal_execute = sa_prodigal_execute,
          prodigal_bin = sa_prodigal_bin,
          unify_bin = sa_unify_bin,
          genemark_execute = sa_genemark_execute,
          genemark_iso_bin = sa_genemark_iso_bin,
          genemark_meta_bin = sa_genemark_meta_bin,
          genemark_meta_model = sa_genemark_meta_model,
          gff_merge_bin = sa_gff_merge_bin,
          fasta_merge_bin = sa_fasta_merge_bin,
          gff_and_fasta_stats_execute = sa_gff_and_fasta_stats_execute,
          gff_and_fasta_stats_bin = sa_gff_and_fasta_stats_bin
      }
    }

    if(fa_execute) {
      call fa.f_annotate {
        input:
          imgap_project_id = imgap_project_id,
          imgap_project_type = imgap_project_type,
          additional_threads = additional_threads,
          output_dir = split,
          input_fasta = s_annotate.proteins,
          ko_ec_execute = fa_ko_ec_execute,
          ko_ec_img_nr_db = fa_ko_ec_img_nr_db,
          ko_ec_md5_mapping = fa_ko_ec_md5_mapping,
          ko_ec_taxon_to_phylo_mapping = fa_ko_ec_taxon_to_phylo_mapping,
          lastal_bin = fa_lastal_bin,
          selector_bin = fa_selector_bin,
          smart_execute = fa_smart_execute,
          smart_db = fa_smart_db,
          par_hmm_inst = fa_par_hmm_inst,
          approx_num_proteins = fa_approx_num_proteins,
          hmmsearch_bin = fa_hmmsearch_bin,
          frag_hits_filter_bin = fa_frag_hits_filter_bin,
          cog_execute = fa_cog_execute,
          cog_db = fa_cog_db,
          tigrfam_execute = fa_tigrfam_execute,
          tigrfam_db = fa_tigrfam_db,
          hit_selector_bin = fa_hit_selector_bin,
          superfam_execute = fa_superfam_excute,
          superfam_db = fa_superfam_db,
          pfam_execute = fa_pfam_execute,
          pfam_db = fa_pfam_db,
          pfam_claninfo_tsv = fa_pfam_claninfo_tsv,
          pfam_clan_filter = fa_pfam_clan_filter,
          cath_funfam_execute = fa_cath_funfam_execute,
          cath_funfam_db = fa_cath_funfam_db,
          signalp_execute = fa_signalp_execute,
          signalp_bin = fa_signalp_bin,
          signalp_gram_stain = fa_signalp_gram_stain,
          tmhmm_execute = fa_tmhmm_execute,
          tmhmm_model = fa_tmhmm_model,
          tmhmm_decode = fa_tmhmm_decode,
          tmhmm_decode_parser = fa_tmhmm_decode_parser,
          sa_gff = s_annotate.gff,
          product_assign_bin = fa_product_assign_bin,
          product_names_mapping_dir = fa_product_names_mapping_dir
      }
    }
  }
}

task setup {
  String file

  command {
    python <<CODE
    import os
    chunksize = 10*1024*1024

    infile = "${file}"
    chunk = 1

    fin = open(infile)

    done = False
    while not done:
       outf = '%s.%d' % (os.path.basename(infile), chunk)
       print(outf)
       fout = open(outf, 'w')
       data = fin.read(chunksize)
       fout.write(data)
       if len(data) < chunksize:
           done = True
       while True:
          line = fin.readline()
          if line.startswith('>') or len(line)==0:
             fin.seek(- len(line), 1)
             break
          fout.write(line)



       chunk += 1

    CODE
    }

  output {
    Array[File] splits = read_lines(stdout())
  }
}


task merge {
  Array[File] files

  command {
      cat ${sep=" " files} > merged.txt
  }
  output {
    File merged = "merged.txt"
  }

}

