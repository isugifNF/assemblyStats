#! /usr/bin/env nextflow

nextflow.enable.dsl=2

/*************************************
 nextflow assemblyStats
 *************************************/

swift_container = 'swift'
busco_container = 'ezlabgva/busco:v5.1.2_cv1'

def helpMessage() {
  log.info isuGIFHeader()
  log.info """
    Usage:
    The typical command for running the pipeline are as follows:
      nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l eukaryota_odb10" -profile condo,singularity
      nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l mollusca_odb10" -profile ceres,singularity --buscoOnly
    Mandatory arguments:
      --genomes                      genome assembly fasta files to run stats on. (./data/*.fasta)
      -profile singularity (docker)  as of now, this workflow only works using singularity or docker and requires this profile [be sure singularity is in your path or loaded by a module]
    Optional arguments:
      --outdir                       Output directory to place final output
      --threads                      Number of CPUs to use during the NanoPlot job [default:40]
      --queueSize                    Maximum number of jobs to be queued [default:18]
      --options                      [default:'--auto-lineage'], you may also consider  "--auto-lineage-prok","--auto-lineage-euk", "-l eukaryota_odb10"
      --listDatasets                 Display the list of available BUSCO lineage datasets to use in --options pipeline parameter.
      --buscoOnly                    When you just want to run a different lineage and not rerun the assemblathon stats
      --account                      Some HPCs require you supply an account name for tracking usage.  You can supply that here.
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

  output: tuple path("list.txt")
  publishDir "${params.outdir}", mode: 'copy'

  script:
  """
  ${busco_app} --list-datasets > list.txt
  """
}



process setupBUSCO {
    // this setup is required because BUSCO runs Augustus that requires writing to the config/species folder.  So this folder must be bound outside of the container and therefore needs to be copied outside the container first.
   container = "$busco_container"
   errorStrategy 'ignore'
   scratch = false
   output:tuple path("config"), path("Busco_version.txt")
//  file("config") into config_ch
//  file("Busco_version.txt")
    publishDir "${params.outdir}", mode: 'copy', pattern: 'Busco_version.txt'
    publishDir "${params.outdir}", mode: 'copy', pattern: 'config'

  script:
  """
  #mkdir ../../../$params.outdir/config
  cp -r /augustus/config .
  echo "$busco_container" > Busco_version.txt
  """
}

process runBUSCO {
  label 'runBUSCO'
  scratch false
  errorStrategy 'finish'
  container = "$busco_container"

  input: tuple val(label), path(genomeFile), path(config)
  output: tuple path("${label}/short_summary.specific.*.txt"), path("${label}/*")
  publishDir "${params.outdir}/BUSCOResults", mode: 'copy', pattern: "${label}/short_summary.specific.*.txt"
  publishDir "${params.outdir}/BUSCO", mode: 'copy', pattern: "${label}/*"
  script:
  """
  PROC=\$((`nproc`))
  cat ${genomeFile} | tr '|' '_' > ${genomeFile.simpleName}_fixheaders.fna
  ${busco_app} \
    -o ${label} \
    -i ${genomeFile.simpleName}_fixheaders.fna \
    ${params.options} \
    -m ${params.mode} \
    -c \${PROC} \
    -f
  """
} 

process runAssemblyStats {
  container = "$swift_container"
  
  input: tuple val(label), path(genomeFile)
  output: path("${label}.assemblyStats")
  publishDir "${params.outdir}/assemblyStats", mode: 'copy', pattern: '*.assemblyStats'
 
  script:
  """
  assemblyStats.swift ${genomeFile} > ${label}.assemblyStats
  """
}

process runAssemblathonStats {
  container = "$swift_container"
  input: tuple val(label), path(genomeFile)
  output: path("${label}.assemblathonStats")
  publishDir "${params.outdir}/assemblathonStats", mode: 'copy', pattern: '*.assemblathonStats'
  script:
  """
  new_Assemblathon.pl  ${genomeFile} > ${label}.assemblathonStats
  """
}
  // assemblyStats.swift ${genomeFile}

workflow {
  if(params.listDatasets) {
    runBUSCOlist | splitText | view
  } else {
    genome_ch = channel.fromPath(params.genome, checkIfExists:true) 
    config_ch = setupBUSCO | map {n -> n.getAt(0)}

    genome_ch | map { file -> [file.simpleName, file] } | combine(config_ch) | runBUSCO

    if(!params.buscoOnly) {
      genome_ch |  map { file -> [file.simpleName, file] } | (runAssemblyStats & runAssemblathonStats)
    }

  }
}

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
  ${c_cyan}  isugifNF/assemblyStats  v${workflow.manifest.version}       ${c_reset}
  -${c_dim}--------------------------------------------------${c_reset}-
  """.stripIndent()
}
