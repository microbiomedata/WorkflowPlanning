import "../tasks/map_hisat2.wdl" as mh
import "../tasks/build_hisat2.wdl" as bh2
import "../tasks/qc.wdl" as qc
import "../tasks/feature_counts.wdl" as fc
import "../tasks/calc_scores.wdl" as cs

workflow metaT {
   Boolean DoQC
   Int cpu
   String outdir
   Array[File] PairedReads=[]
   File ref_genome
   File ref_gff
   File? SingleRead
   String? QCopts=""
   String? projectName = "metatranscriptomics"
   String container = "docker:migun/nmdc_metat:latest"

	if (DoQC){
		call qc.shift_qc{
			input: opts = QCopts,
			cpu = cpu,
			projectName = projectName,
			outdir = outdir,
			PairedReads = PairedReads,
			QCSingleRead = SingleRead,
			container = container
		}
	}

	call bh2.shift_BuildHisat2{
		input: cpu = cpu,
		ref_genome = ref_genome,
		container = container
	}

	call mh.shift_mapping{
		input: cpu = cpu,
		PairedReads = if DoQC then shift_qc.QCedPaired else PairedReads,
		hisat2_ref = shift_BuildHisat2.hs,
		db = shift_BuildHisat2.db,
		projectName = projectName,
		container = container
	}

	call fc.shift_featurecount{
		input: cpu = cpu,
		projectName = projectName,
		ref_gff = ref_gff,
		bam_file = shift_mapping.map_bam,
		container = container
	}

	call cs.shift_CalScores{
		input: cpu = cpu,
		projectName = projectName,
		fc_file = shift_featurecount.ct_tbl,
		container = container
	}
	
	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}
}

