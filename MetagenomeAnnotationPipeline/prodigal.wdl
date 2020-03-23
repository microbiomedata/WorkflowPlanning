workflow prodigal {

  String imgap_input_fasta
  String imgap_project_id
  String prodigal_bin =  "/opt/omics/bin/prodigal"
  String prodigal_unify_bin =  "/opt/omics/bin/structural_annotation/unify_gene_ids.py"

  call metag {
    input:
      bin = prodigal_bin,
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id
  }

  call clean_and_unify {
    input:
      meta_proteins_fasta = metag.proteins,
      meta_genes_fasta = metag.genes,
      meta_gff = metag.gff,
      unify_bin = prodigal_unify_bin,
      project_id = imgap_project_id,
  }

  output {
    File gff = clean_and_unify.gff
    File genes = clean_and_unify.genes
    File proteins = clean_and_unify.proteins
  }
}

task fasta_len {

  File input_fasta

  command {
    grep -v '^>' ${input_fasta} | wc -m
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
    Int wc = select_first([read_int(stdout()),0])
  }
}

task metag {

  String bin
  File   input_fasta
  String project_id

  command {
    ${bin} -f gff -p meta -m -i ${input_fasta} \
    -o ${project_id}_prodigal.gff -d ${project_id}_prodigal_genes.fna \
    -a ${project_id}_prodigal_proteins.faa
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
    File gff = "${project_id}_prodigal.gff"
    File genes = "${project_id}_prodigal_genes.fna"
    File proteins = "${project_id}_prodigal_proteins.faa"
  }
}

task clean_and_unify {
  
  File?  meta_proteins_fasta
  File?  meta_genes_fasta
  File?  meta_gff
  String unify_bin
  String project_id

  command {
    sed -i 's/\*$//g' ${meta_proteins_fasta}
    sed -i 's/\*/X/g' ${meta_proteins_fasta}
    ${unify_bin} ${meta_gff} \
                 ${meta_genes_fasta} \
                 ${meta_proteins_fasta}
    mv ${meta_proteins_fasta} . 2> /dev/null
    mv ${meta_genes_fasta} . 2> /dev/null
    mv ${meta_gff} . 2> /dev/null
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
    File gff = "${project_id}_prodigal.gff"
    File genes = "${project_id}_prodigal_genes.fna"
    File proteins = "${project_id}_prodigal_proteins.faa"
  }
}

