process runBUSCO {

  container = "$nanoplot_container"

  publishDir "${params.outdir}/nanoplots/", mode: 'copy', pattern: '*/*.png'
  publishDir "${params.outdir}/pdf", mode: 'copy', pattern: '*/*.pdf'
  publishDir "${params.outdir}/nanoplots/log", mode: 'copy', pattern: '*/*.log'
  publishDir "${params.outdir}/nanoplots/", mode: 'copy', pattern: '*/*.md'


  input:
  set val(label), file(fastq) from fastq_reads_qc


  output:
  file("*/*.png") into nanoplot_png
  file("*/*.pdf") into nanoplot_pdf
  file("*/*.log") into nanoplot_log
  file("*/*.md") into nanoplot_md

  script:

  """


  """

}

process runAssemblathonStats {

  container = "$downpore_container"


  publishDir "${params.outdir}/trimmedReads", mode: 'copy', pattern: '*_adaptersRemoved.fastq'


  input:
  set val(label), file(fastq) from fastq_reads_trim
  file front from adapters_front_ch.val
  file back from adapters_back_ch.val

  output:
  file("*_adaptersRemoved.fastq") into trimmed_reads


  script:
  """

  """


}


## ERROR

SystemExit: Cannot write to Augustus species folder, please make sure you have write permissions to /augustus/config/species


nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir greenStats --threads 1 --options "-l mammalia_odb10" -profile condo,singularity


singularity run --writable-tmpfs busco_v4.1.2_cv1.sif busco -i polhead.fasta -o outdir -l mammalia_odb10 -c 16 --mode genome -f
singularity run --writable-tmpfs busco_v4.1.2_cv1.sif cp -r /augustus/config .
export AUGUSTUS_CONFIG_PATH="$PWD/config"
