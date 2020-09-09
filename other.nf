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
