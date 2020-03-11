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

	if (DoQC){
		call qc.qc{
			input: opts = QCopts,
			cpu = cpu,
			projectName = projectName,
			outdir = outdir,
			PairedReads = PairedReads,
			QCSingleRead = SingleRead
		}
	}

	call bh2.BuildHisat2{
		input: cpu = cpu,
		ref_genome = ref_genome
	}

	call mh.mapping{
		input: cpu = cpu,
		PairedReads = if DoQC then qc.QCedPaired else PairedReads,
		hisat2_ref = BuildHisat2.hs,
		db = BuildHisat2.db,
		projectName = projectName
	}

	call fc.featurecount{
		input: cpu = cpu,
		projectName = projectName,
		ref_gff = ref_gff,
		bam_file = mapping.map_bam
	}

	call cs.CalScores{
		input: cpu = cpu,
		projectName = projectName,
		fc_file = featurecount.ct_tbl
	}

	
	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}
}

