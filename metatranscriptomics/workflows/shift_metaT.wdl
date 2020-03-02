import "../tasks/map_hisat2.wdl" as mh
import "../tasks/build_hisat2.wdl" as bh2
import "../tasks/qc.wdl" as qc
import "../tasks/feature_counts.wdl" as fc

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
		call qc.shift_qc{
			input: opts = QCopts,
			cpu = cpu,
			projectName = projectName,
			outdir = outdir,
			PairedReads = PairedReads,
			QCSingleRead = SingleRead
		}
	}

	call bh2.shift_BuildHisat2{
		input: cpu = cpu,
		ref_genome = ref_genome
	}

	call mh.shift_mapping{
		input: cpu = cpu,
		PairedReads = if DoQC then qc.QCedPaired else PairedReads,
		hisat2_ref = BuildHisat2.hisat2_index,
		ref_genome = ref_genome,
		projectName = projectName
	}

	call fc.shift_featurecount{
		input: cpu = cpu,
		projectName = projectName,
		ref_gff = ref_gff,
		bam_file = mapping.map_bam
	}


	
	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}
}

