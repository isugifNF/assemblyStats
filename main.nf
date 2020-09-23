#! /usr/bin/env nextflow

/*************************************
 nextflow nanoQCtrim
 *************************************/

swift_container = 'swift'
//  busco_container = 'ezlabgva/busco:v4.1.2_cv1'
busco_container = 'quay.io/biocontainers/busco:3.0.2--py_13'
downpore_container = 'quay.io/biocontainers/downpore:0.3.3--h375a9b1_0'

 def helpMessage() {
     log.info isuGIFHeader()
     log.info """
      Usage:
      The typical command for running the pipeline are as follows:

      nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l eukaryota_odb10" -profile condo,singularity
      nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l mollusca_odb10" -profile condo,singularity --buscoOnly

      Mandatory arguments:

      --genomes                      genome assembly fasta files to run stats on. (./data/*.fasta)
      -profile singularity           as of now, this workflow only works using singularity and requires this profile [be sure singularity is in your path]

      Optional arguments:
      --outdir                       Output directory to place final output
      --threads                      Number of CPUs to use during the NanoPlot job [16]
      --queueSize                    Maximum number of jobs to be queued [18]
      --options                      ["--auto-lineage"], you may also consider  "--auto-lineage-prok","--auto-lineage-euk",""-l eukaryota_odb10"
      --listDatasets                 Display the list of available BUSCO lineage datasets to use in --options pipeline parameter.
      buscoOnly                      When you just want to run a different lineage and not rerun the assemblathon stats
      --help                         This usage statement.
     """
}

     // Show help message
if (params.help) {
   helpMessage()
   exit 0
}

  process runBUSCOlist  {
  container = "$busco_container"

  when:
  params.listDatasets == true

  output:
  file("list.txt")
  publishDir "${params.outdir}"
  stdout result

  script:
  """
  busco --list-datasets > list.txt
  cat list.txt
  """
  }

  result.subscribe { println it }


if (!params.listDatasets) {
  Channel
   .fromPath(params.genomes)
   .map { file -> tuple(file.simpleName, file) }
   .into { genome_runAssemblyStats; genome_runAssemblathonStats; genome_BUSCO }


  if (!params.buscoOnly) {
    process runAssemblyStats {

    container = "$swift_container"

    input:
    set val(label), file(genomeFile) from genome_runAssemblyStats

    output:
    file("${label}.assemblyStats")
    publishDir "${params.outdir}/assemblyStats", mode: 'copy', pattern: '*.assemblyStats'

    script:
    """
     assemblyStats.swift ${genomeFile} > ${label}.assemblyStats
    """
    // assemblyStats.swift ${genomeFile}
    }

    process runAssemblathonStats {

    container = "$swift_container"

    input:
    set val(label), file(genomeFile) from genome_runAssemblathonStats

    output:
    file("${label}.assemblathonStats")
    publishDir "${params.outdir}/assemblathonStats", mode: 'copy', pattern: '*.assemblathonStats'

    script:
    """
    new_Assemblathon.pl  ${genomeFile} > ${label}.assemblathonStats
    """
    // assemblyStats.swift ${genomeFile}
    }
  } // end buscoOnly

  process setupBUSCO {
  // this setup is required because BUSCO runs Augustus that requires writing to the config/species folder.  So this folder must be bound outside of the container and therefore needs to be copied outside the container first.

  container = "$busco_container"

  output:
  publishDir "${params.outdir}"
//busco4  file("config") into config_ch
file("augustus/config") into config_ch

  script:
  """
  # cp -r /augustus/config . #busco4
  mkdir augustus
  cp -r /usr/local/config augustus/config
  """

  }

  process runBUSCO {
  label 'runBUSCO'

  container = "$busco_container"
//  containerOptions = "--bind $launchDir/$params.outdir/config:/augustus/config"
  containerOptions = "--bind $launchDir/$params.outdir/augustus/config:/augustus/config"
  input:
  set val(label), file(genomeFile) from genome_BUSCO
  file(config) from config_ch.val

  output:
  file("${label}/short_summary.specific.*.txt")
  publishDir "${params.outdir}/BUSCOResults/${label}/", mode: 'copy', pattern: "${label}/short_summary.specific.*.txt"
  file("${label}/*")
  publishDir "${params.outdir}/BUSCO"



  script:
  """
  #alias busco=run_BUSCO.py
  #busco \
  run_BUSCO.py
  -o ${label} \
  -i ${genomeFile} \
  ${params.options} \
  -m ${params.mode} \
  -c ${params.threads} \
  -f
  """
  // assemblyStats.swift ${genomeFile}
  }

} // end if not listDatasets

    def isuGIFHeader() {
        // Log colors ANSI codes
        c_reset = params.monochrome_logs ? '' : "\033[0m";
        c_dim = params.monochrome_logs ? '' : "\033[2m";
        c_black = params.monochrome_logs ? '' : "\033[1;90m";
        c_green = params.monochrome_logs ? '' : "\033[1;92m";
        c_yellow = params.monochrome_logs ? '' : "\033[1;93m";
        c_blue = params.monochrome_logs ? '' : "\033[1;94m";
        c_purple = params.monochrome_logs ? '' : "\033[1;95m";
        c_cyan = params.monochrome_logs ? '' : "\033[1;96m";
        c_white = params.monochrome_logs ? '' : "\033[1;97m";
        c_red = params.monochrome_logs ? '' :  "\033[1;91m";

        return """    -${c_dim}--------------------------------------------------${c_reset}-
        ${c_white}                                ${c_red   }\\\\------${c_yellow}---//       ${c_reset}
        ${c_white}  ___  ___        _   ___  ___  ${c_red   }  \\\\---${c_yellow}--//        ${c_reset}
        ${c_white}   |  (___  |  | / _   |   |_   ${c_red   }    \\-${c_yellow}//         ${c_reset}
        ${c_white}  _|_  ___) |__| \\_/  _|_  |    ${c_red  }    ${c_yellow}//${c_red  } \\        ${c_reset}
        ${c_white}                                ${c_red   }  ${c_yellow}//---${c_red  }--\\\\       ${c_reset}
        ${c_white}                                ${c_red   }${c_yellow}//------${c_red  }---\\\\       ${c_reset}
        ${c_cyan}  isugifNF/nanoQCtrim  v${workflow.manifest.version}       ${c_reset}
        -${c_dim}--------------------------------------------------${c_reset}-
        """.stripIndent()
    }
