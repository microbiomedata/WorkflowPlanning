workflow genemark {
  
  String imgap_input_fasta
  String imgap_project_id
  String genemark_meta_bin = "/opt/omics/bin/gmhmmp2"
  String genemark_meta_model = "/opt/omics/programs/GeneMark/GeneMarkS-2/v1.07/mgm_11.mod"
  String genemark_unify_bin  = "/opt/omics/bin/structural_annotation/unify_gene_ids.py"

  call gm_meta {
    input:
      bin = genemark_meta_bin,
      model = genemark_meta_model,
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id
  }
  call clean_and_unify {
    input:
      meta_genes_fasta = gm_meta.genes,
      meta_proteins_fasta = gm_meta.proteins,
      meta_gff = gm_meta.gff,
      unify_bin = genemark_unify_bin,
      project_id = imgap_project_id
  }

  output {
    File gff = clean_and_unify.gff
    File genes = clean_and_unify.genes
    File proteins = clean_and_unify.proteins
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

  File?  meta_genes_fasta
  File?  meta_proteins_fasta
  File?  meta_gff
  String unify_bin
  String project_id
  
  command {
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
    File gff = "${project_id}_genemark.gff"
    File genes = "${project_id}_genemark_genes.fna"
    File proteins = "${project_id}_genemark_proteins.faa"
  }
}
