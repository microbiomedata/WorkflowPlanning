import "ReadbasedAnalysisTasks.wdl" as tp

workflow ReadbasedAnalysis {
    Map[String, Boolean] enabled_tools
    Map[String, String] db
    Array[File] reads
    Int cpu
    String prefix
    String outdir
    Boolean? paired = false

    if (enabled_tools["gottcha2"] == true) {
        call tp.profilerGottcha2 {
            input: READS = reads,
                   DB = db["gottcha2"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/gottcha2",
                   CPU = cpu
        }
    }
    if (enabled_tools["kraken2"] == true) {
        call tp.profilerKraken2 {
            input: READS = reads,
                   PAIRED = paired,
                   DB = db["kraken2"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/kraken2",
                   CPU = cpu
        }
    }
    if (enabled_tools["centrifuge"] == true) {
        call tp.profilerCentrifuge {
            input: READS = reads,
                   DB = db["centrifuge"],
                   PREFIX = prefix,
                   OUTPATH = outdir+"/centrifuge",
                   CPU = cpu
        }
    }
    meta {
        author: "Po-E Li, B10, LANL"
        email: "po-e@lanl.gov"
    }
}
