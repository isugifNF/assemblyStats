# assemblyStats

```
----------------------------------------------------
                                    \\---------//       
      ___  ___        _   ___  ___    \\-----//        
       |  (___  |  | / _   |   |_       \-//         
      _|_  ___) |__| \_/  _|_  |        // \        
                                      //-----\\       
                                    //---------\\       
      isugifNF/assemblyStats  v1.0.0       
    ----------------------------------------------------
```

[Genome Informatics Facility](https://gif.biotech.iastate.edu/) | [![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.10.0-brightgreen.svg)](https://www.nextflow.io/)

---



### Introduction

**isugifNF/assemblyStats** is a nextflow pipeline to assess the quality of your genome assembl(y/ies).  It runs three separate programs

* [AssemblyStats](https://github.com/ISUgenomics/swift/blob/master/bin/assemblyStats.swift)
  * I found AssemblathonStats formatting to be not to my liking so I rewrote the script to output the same statistics but in an easier to read format with a few additional outputs such as the top 5 largest and smallest scaffolds
  * <details><summary>Example</summary>

    <pre>


    </pre>
    </details>
* [AssemblathonStats](https://github.com/KorfLab/Assemblathon/blob/master/assemblathon_stats.pl)
  * Technically this is a modified version of this script that includes N90/L90 as well.
  * <details><summary>Example</summary>

    <pre>


    </pre>
    </details>
* [BUSCO](https://busco.ezlab.org) Benchmarking Universal Single Copy Orthologs
  * <details><summary>Example</summary>

    <pre>


    </pre>
    </details>

Run Assembly statistics on a genome assembly (BUSCO and assemblyStats and new_Assemblathon.pl)

### Installation and running


<details><summary>see usage statement</summary>

```
Usage:
    The typical command for running the pipeline are as follows:

    nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l eukaryota_odb10" -profile condo,singularity
    nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l mollusca_odb10" -profile condo,singularity --buscoOnly

    Mandatory arguments:

    --genomes                      genome assembly fasta files to run stats on. (./data/*.fasta)
    -profile singularity (docker)           as of now, this workflow only works using singularity or docker and requires this profile [be sure singularity is in your path]

    Optional arguments:
    --outdir                       Output directory to place final output
    --threads                      Number of CPUs to use during the NanoPlot job [16]
    --queueSize                    Maximum number of jobs to be queued [18]
    --options                      ["--auto-lineage"], you may also consider  "--auto-lineage-prok","--auto-lineage-euk",""-l eukaryota_odb10"
    --listDatasets                 Display the list of available BUSCO lineage datasets to use in --options pipeline parameter.
    buscoOnly                      When you just want to run a different lineage and not rerun the assemblathon stats
    --help                         This usage statement.

```

</details>


### Dependencies if running locally

Nextflow is written in groovy which requires java version 1.8 or greater (check version using `java -version`). But otherwise can be installed if you have a working linux command-line.

```
java -version
curl -s https://get.nextflow.io | bash

# Check to see if nextflow is created
ls -ltr nextflow
#> total 32
#> -rwx--x--x  1 username  staff    15K Aug 12 12:47 nextflow
```

First let's look at the help message
```
nextflow run isugifNF/assemblyStats --help
```
<details><summary>Output</summary>

              <pre>
              N E X T F L O W  ~  version 20.07.1
              Launching `isugifNF/assemblyStats/main.nf` [magical_colden] - revision: a156628d62
              ----------------------------------------------------
                                                  \\---------//       
                    ___  ___        _   ___  ___    \\-----//        
                     |  (___  |  | / _   |   |_       \-//         
                    _|_  ___) |__| \_/  _|_  |        // \        
                                                    //-----\\       
                                                  //---------\\       
                    isugifNF/nanoQCtrim  v1.0.0       
                  ----------------------------------------------------
              Usage:
                    The typical command for running the pipeline are as follows:

                    nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l eukaryota_odb10" -profile condo,singularity
                    nextflow run isugifNF/assemblyStats --genomes "*fasta" --outdir newStats3 --threads 16 --options "-l mollusca_odb10" -profile condo,singularity --buscoOnly

                    Mandatory arguments:

                    --genomes                      genome assembly fasta files to run stats on. (./data/*.fasta)
                    -profile singularity (docker)          as of now, this workflow only works using singularity or docker and requires this profile [be sure singularity is in your path or loaded by a module]

                    Optional arguments:
                    --outdir                       Output directory to place final output
                    --threads                      Number of CPUs to use during the NanoPlot job [16]
                    --queueSize                    Maximum number of jobs to be queued [18]
                    --options                      ["--auto-lineage"], you may also consider  "--auto-lineage-prok","--auto-lineage-euk",""-l eukaryota_odb10"
                    --listDatasets                 Display the list of available BUSCO lineage datasets to use in --options pipeline parameter.
                    buscoOnly                      When you just want to run a different lineage and not rerun the assemblathon stats
                    --help                         This usage statement.

              </pre>
</details>

We can get a list of the BUSCO datasets we can run using this set of parameters.  The `-profile docker` is important as this workflow relies on containers and will error out if you don't use `docker` or `singularity`

```
nextflow run isugifNF/assemblyStats --listDatasets -profile docker
```
<details><summary>Output</summary>

<pre>
            N E X T F L O W  ~  version 20.07.1
Launching `isugifNF/assemblyStats/main.nf` [amazing_colden] - revision: a156628d62
executor >  local (1)
[6c/31848c] process > runBUSCOlist [  0%] 0 of 1
INFO:	Downloading information on latest versions of BUSCO data...
INFO:	Downloading file 'https://busco-data.ezlab.org/v4/data/information/lineages_list.2019-11-27.txt.tar.gz'
INFO:	Decompressing file '/Users/severin/work/6c/31848cd8f040c93f4047d085609d69/busco_downloads/information/lineages_list.2019-11-27.txt.tar.gz'

################################################

Datasets available to be used with BUSCOv4 as of 2019/11/27:

 bacteria_odb10
     - acidobacteria_odb10
     - actinobacteria_phylum_odb10
         - actinobacteria_class_odb10
             - corynebacteriales_odb10
             - micrococcales_odb10
             - propionibacteriales_odb10
             - streptomycetales_odb10
             - streptosporangiales_odb10
         - coriobacteriia_odb10
             - coriobacteriales_odb10
     - aquificae_odb10
     - bacteroidetes-chlorobi_group_odb10
         - bacteroidetes_odb10
             - bacteroidia_odb10
                 - bacteroidales_odb10
             - cytophagia_odb10
                 - cytophagales_odb10
             - flavobacteriia_odb10
                 - flavobacteriales_odb10
             - sphingobacteriia_odb10
         - chlorobi_odb10
     - chlamydiae_odb10
     - chloroflexi_odb10
     - cyanobacteria_odb10
         - chroococcales_odb10
         - nostocales_odb10
         - oscillatoriales_odb10
         - synechococcales_odb10
     - firmicutes_odb10
         - bacilli_odb10
             - bacillales_odb10
             - lactobacillales_odb10
         - clostridia_odb10
             - clostridiales_odb10
             - thermoanaerobacterales_odb10
         - selenomonadales_odb10
         - tissierellia_odb10
             - tissierellales_odb10
     - fusobacteria_odb10
         - fusobacteriales_odb10
     - planctomycetes_odb10
     - proteobacteria_odb10
         - alphaproteobacteria_odb10
             - rhizobiales_odb10
                 - rhizobium-agrobacterium_group_odb10
             - rhodobacterales_odb10
             - rhodospirillales_odb10
             - rickettsiales_odb10
             - sphingomonadales_odb10
         - betaproteobacteria_odb10
             - burkholderiales_odb10
             - neisseriales_odb10
             - nitrosomonadales_odb10
         - delta-epsilon-subdivisions_odb10
             - deltaproteobacteria_odb10
                 - desulfobacterales_odb10
                 - desulfovibrionales_odb10
                 - desulfuromonadales_odb10
             - epsilonproteobacteria_odb10
                 - campylobacterales_odb10
         - gammaproteobacteria_odb10
             - alteromonadales_odb10
             - cellvibrionales_odb10
             - chromatiales_odb10
             - enterobacterales_odb10
             - legionellales_odb10
             - oceanospirillales_odb10
             - pasteurellales_odb10
             - pseudomonadales_odb10
             - thiotrichales_odb10
             - vibrionales_odb10
             - xanthomonadales_odb10
     - spirochaetes_odb10
         - spirochaetia_odb10
             - spirochaetales_odb10
     - synergistetes_odb10
     - tenericutes_odb10
         - mollicutes_odb10
             - entomoplasmatales_odb10
             - mycoplasmatales_odb10
     - thermotogae_odb10
     - verrucomicrobia_odb10
 archaea_odb10
     - thaumarchaeota_odb10
     - thermoprotei_odb10
         - thermoproteales_odb10
         - sulfolobales_odb10
         - desulfurococcales_odb10
     - euryarchaeota_odb10
         - thermoplasmata_odb10
         - methanococcales_odb10
         - methanobacteria_odb10
         - methanomicrobia_odb10
             - methanomicrobiales_odb10
         - halobacteria_odb10
             - halobacteriales_odb10
             - natrialbales_odb10
             - haloferacales_odb10
 eukaryota_odb10
     - alveolata_odb10
         - apicomplexa_odb10
             - aconoidasida_odb10
                 - plasmodium_odb10
             - coccidia_odb10
     - euglenozoa_odb10
     - fungi_odb10
         - ascomycota_odb10
             - dothideomycetes_odb10
                 - capnodiales_odb10
                 - pleosporales_odb10
             - eurotiomycetes_odb10
                 - chaetothyriales_odb10
                 - eurotiales_odb10
                 - onygenales_odb10
             - leotiomycetes_odb10
                 - helotiales_odb10
             - saccharomycetes_odb10
             - sordariomycetes_odb10
                 - glomerellales_odb10
                 - hypocreales_odb10
         - basidiomycota_odb10
             - agaricomycetes_odb10
                 - agaricales_odb10
                 - boletales_odb10
                 - polyporales_odb10
             - tremellomycetes_odb10
         - microsporidia_odb10
         - mucoromycota_odb10
             - mucorales_odb10
     - metazoa_odb10
         - arthropoda_odb10
             - arachnida_odb10
             - insecta_odb10
                 - endopterygota_odb10
                     - diptera_odb10
                     - hymenoptera_odb10
                     - lepidoptera_odb10
                 - hemiptera_odb10
         - mollusca_odb10
         - nematoda_odb10
         - vertebrata_odb10
             - actinopterygii_odb10
                 - cyprinodontiformes_odb10
             - tetrapoda_odb10
                 - mammalia_odb10
                     - eutheria_odb10
                         - euarchontoglires_odb10
                             - glires_odb10
                             - primates_odb10
                         - laurasiatheria_odb10
                             - carnivora_odb10
                             - cetartiodactyla_odb10
                 - sauropsida_odb10
                     - aves_odb10
                         - passeriformes_odb10
     - stramenopiles_odb10
     - viridiplantae_odb10
         - chlorophyta_odb10
         - embryophyta_odb10
             - liliopsida_odb10
                 - poales_odb10
             - eudicots_odb10
                 - brassicales_odb10
                 - fabales_odb10
                 - solanales_odb10
executor >  local (1)
[6c/31848c] process > runBUSCOlist [100%] 1 of 1 ✔

            </pre>
</details>

Let's use a small Bacterial genome for the test. So we will use  bacteria_odb10

```
 nextflow run isugifNF/assemblyStats --genomes "P*.fasta"  --options "-l bacteria_odb10" -profile docker --threads 4
```

### Credits
