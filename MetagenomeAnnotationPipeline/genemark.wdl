workflow genemark {
  
  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  String output_dir
  String genemark_iso_bin
  String genemark_meta_bin
  String genemark_meta_model
  String genemark_unify_bin

  if(imgap_project_type == "isolate") {
    call gm_isolate {
      input:
        bin = genemark_iso_bin,
        input_fasta = imgap_input_fasta,
        project_id = imgap_project_id
    }
  }
  if(imgap_project_type == "metagenome") {
    call gm_meta {
      input:
        bin = genemark_meta_bin,
        model = genemark_meta_model,
        input_fasta = imgap_input_fasta,
        project_id = imgap_project_id
    }
  }
  call clean_and_unify {
    input:
      iso_genes_fasta = gm_isolate.genes,
      meta_genes_fasta = gm_meta.genes,
      iso_proteins_fasta = gm_isolate.proteins,
      meta_proteins_fasta = gm_meta.proteins,
      iso_gff = gm_isolate.gff,
      meta_gff = gm_meta.gff,
      unify_bin = genemark_unify_bin,
      project_id = imgap_project_id,
      out_dir = output_dir
  }

  output {
    File gff = clean_and_unify.gff
    File genes = clean_and_unify.genes
    File proteins = clean_and_unify.proteins
  }
}

task gm_isolate {
  
  String bin
  File   input_fasta
  String project_id

  command {
    ${bin} --seq ${input_fasta} --genome-type auto \
           --output ${project_id}_genemark.gff --format gff \
           --fnn ${project_id}_genemark_genes.fna \
           --faa ${project_id}_genemark_proteins.faa
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
    File gff = "${project_id}_genemark.gff"
    File genes = "${project_id}_genemark_genes.fna"
    File proteins = "${project_id}_genemark_proteins.faa"
  }
}

task gm_meta {
  
  String bin
  String model
  File   input_fasta
  String project_id

  command {
    ${bin} --Meta ${model} --incomplete_at_gaps 30 \
           -o ${project_id}_genemark.gff \
           --format gff --NT ${project_id}_genemark_genes.fna \
           --AA ${project_id}_genemark_proteins.faa --seq ${input_fasta}
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
    File gff = "${project_id}_genemark.gff"
    File genes = "${project_id}_genemark_genes.fna"
    File proteins = "${project_id}_genemark_proteins.faa"
  }
}

task clean_and_unify {

  File?  iso_genes_fasta
  File?  meta_genes_fasta
  File?  iso_proteins_fasta
  File?  meta_proteins_fasta
  File?  iso_gff
  File?  meta_gff
  String unify_bin
  String project_id
  String out_dir
  
  command {
    sed -i 's/\*/X/g' ${iso_proteins_fasta} ${meta_proteins_fasta}
    ${unify_bin} ${iso_gff} ${meta_gff} \
                 ${iso_genes_fasta} ${meta_genes_fasta} \
                 ${iso_proteins_fasta} ${meta_proteins_fasta}
    mv ${iso_proteins_fasta} . 2> /dev/null
    mv ${meta_proteins_fasta} . 2> /dev/null
    mv ${iso_genes_fasta} . 2> /dev/null
    mv ${meta_genes_fasta} . 2> /dev/null
    mv ${iso_gff} . 2> /dev/null
    mv ${meta_gff} . 2> /dev/null
    #cp -r ./${project_id}_genemark* ${out_dir}
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
    File gff = "${project_id}_genemark.gff"
    File genes = "${project_id}_genemark_genes.fna"
    File proteins = "${project_id}_genemark_proteins.faa"
  }
}
