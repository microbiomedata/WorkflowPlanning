task qc{
    Array[File] PairedReads
    File? QCSingleRead
    String opts
    Int cpu
    String projectName
    String outdir

    # need to add shifter command here when running it in NERSC
    command {
        FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
    }

    output{
        Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',
                                  outdir+'/QC.2.trimmed.fastq']
        File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
        File QCstat = outdir + "/QC.stats.txt"
        File QCstatPDF = outdir + "/QC_qc_report.pdf"
    }

}

task shift_qc{
    Array[File] PairedReads
    File? QCSingleRead
    String opts
    Int cpu
    String projectName
    String outdir
    String container

    command {
        shifter --image=${container} FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
    }

    output{
        Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',
                                  outdir+'/QC.2.trimmed.fastq']
        File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
        File QCstat = outdir + "/QC.stats.txt"
        File QCstatPDF = outdir + "/QC_qc_report.pdf"
    }

    runtime {
        poolname: "aim2_metaT"
        cluster: "cori"
        time: "00:15:00"
        cpu: cpu
        mem: "115GB"
        node: 1
        nwpn: 4 # number of workers per node(up to 32).  This depends on the job's memory & thread requirements.
    }

    meta {
        author: "migun shakya, B10, LANL"
        email: "migun@lanl.gov"
    }
}

task dock_qc{
    Array[File] PairedReads
    File? QCSingleRead
    String opts
    Int cpu
    String projectName
    String outdir

    # need to add shifter command here when running it in NERSC
    command {
        FaQCs -1 ${PairedReads[0]} -2 ${PairedReads[1]} -d ${outdir} -t ${cpu} ${opts}
    }

    output{
        Array[File] QCedPaired = [outdir+'/QC.1.trimmed.fastq',outdir+'/QC.2.trimmed.fastq']
        File QCedSingle = outdir + "/" + "QC.unpaired.trimmed.fastq"
        File QCstat = outdir + "/QC.stats.txt"
        File QCstatPDF = outdir + "/QC_qc_report.pdf"
    }

    runtime {
        docker: 'migun/nmdc_metat:latest'
    }
}