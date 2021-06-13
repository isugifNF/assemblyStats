#!/usr/bin/env swift

//  File.swift
//
//  Created by Andrew J Severin on 5/29/20.
//

import Foundation

// COMMANDLINE IN/OUT and ARGUMENTS
    var stderr = StandardErrorOutputStream()
    var stdout = StandardOutputStream()

    if CommandLine.arguments.count < 2 {
        usage()
//        print("Please provide the fasta file as input", to: &stderr)
//        exit(0)
    }


// READ IN THE FASTA FILE
    let path = CommandLine.arguments[1]
    let reader = LineReader(path: path)

    // create a struct to hold the fasta sequences with functions for GC content and def and seq variables
    struct fasta {

        // variables for the definition and Sequence lines of the fasta and nucleotide count
        var def: String
        var length = 0  // Function to get the length of the sequence
    }

    var fastas: [fasta] = [fasta]()  //create an empty array of fasta structs to hold the sequences from the FASTA file
    var fastaNum = -1  // store the fasta struct number, this way we can append all the sequence to the seq variable corresponding to the current fastaNum struct.

    reader?.forEach { line in

        if line.starts(with: ">") {
            //create an empty fasta struct
             var createfasta = fasta(def: "") //, seq: "")
            // add the defline into the struct for a scaffold
            fastaNum += 1
            createfasta.def = line.trimmingCharacters(in: .whitespacesAndNewlines)
            fastas.append(createfasta)
          //  print(createfasta.def)
        } else if line.starts(with: "#"){
            // print the lines that are comments
            print(line)
        } else {


            fastas[fastaNum].length += line.trimmingCharacters(in: .whitespacesAndNewlines).count
        }
    }


// Total Number of Scaffolds and Sorting from Largest to Smallest
    let numScaffs = fastas.count  // get the total number of scaffolds/fasta entries in the fasta file

    if numScaffs > 1 {  // verify that there is something to sort.
    fastas.sort(by: {  // This sorts the fastas array of structs by length replacing the original ordering.
        $0.length > $1.length
    })
    }

    let fastaLengths = fastas.map( {$0.length})  // Calculate the sum of the fasta lengths

// Variables for Number of Scaffolds of different sizes
    var NumScaffsLess1KA = fastaLengths.indices.filter({ fastaLengths[$0] < 1000})
    let NumScaffsLess1K = NumScaffsLess1KA.count
    var NumScaffsGtr1KA = fastaLengths.indices.filter({ fastaLengths[$0] > 999 && fastaLengths[$0] < 10000})
    let NumScaffsGtr1K = NumScaffsGtr1KA.count
    var NumScaffsGtr10KA = fastaLengths.indices.filter({ fastaLengths[$0] > 9999 && fastaLengths[$0] < 100000})
    let NumScaffsGtr10K = NumScaffsGtr10KA.count
    var NumScaffsGtr100KA = fastaLengths.indices.filter({ fastaLengths[$0] > 99999 && fastaLengths[$0] < 1000000})
    let NumScaffsGtr100K = NumScaffsGtr100KA.count
    var NumScaffsGtr1MA = fastaLengths.indices.filter({ fastaLengths[$0] > 999999 && fastaLengths[$0] < 10000000})
    let NumScaffsGtr1M = NumScaffsGtr1MA.count
    var NumScaffsGtr10MA = fastaLengths.indices.filter({ fastaLengths[$0] > 9999999 })
    let NumScaffsGtr10M = NumScaffsGtr10MA.count


// Variables for the total nucleotide content for scaffolds of different sizes.
    var NcountScaffsLess1KA = fastaLengths.filter({$0 < 1000})
    let NcountScaffsLess1K = NcountScaffsLess1KA.sum()
    var NcountScaffsGtr1KA = fastaLengths.filter({ $0 > 999 && $0 < 10000})
    let NcountScaffsGtr1K = NcountScaffsGtr1KA.sum()
    var NcountScaffsGtr10KA = fastaLengths.filter({ $0 > 9999 && $0 < 100000})
    let NcountScaffsGtr10K = NcountScaffsGtr10KA.sum()
    var NcountScaffsGtr100KA = fastaLengths.filter({ $0 > 99999 && $0 < 1000000})
    let NcountScaffsGtr100K = NcountScaffsGtr100KA.sum()
    var NcountScaffsGtr1MA = fastaLengths.filter({ $0 > 999999 && $0 < 10000000})
    let NcountScaffsGtr1M = NcountScaffsGtr1MA.sum()
    var NcountScaffsGtr10MA = fastaLengths.filter({ $0 > 9999999 })
    let NcountScaffsGtr10M = NcountScaffsGtr10MA.sum()

// Grab total nucleotide counts for assembly and each nucleotide
    let totalNucleotideContent = fastaLengths.sum()


// FUNCTIONS to calculate percentTotal, Median and N50/N90
    func percentOfTotal(count: Int, totalCount: Int) -> String {
        let a = Float(count)
        let b = Float(totalCount)
        return String(String(a*100/b).prefix(5))
    }

    func calculateMedian(array: [Int], isSorted: Bool) -> Float {
        // improved upon from https://stackoverflow.com/questions/44450266/get-median-of-array
        var sorted = array
        if isSorted == false {
            sorted = array.sorted()
        }

        if sorted.count % 2 == 0 {
            return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
        } else {
            return Float(sorted[(sorted.count - 1) / 2])
        }
    }

    let cumsumNucleotideContent = fastaLengths.cumsum()
    func NXX(value: Int) -> ([Int]) {
        // https://stackoverflow.com/questions/45933149/swift-how-to-get-indexes-of-filtered-items-of-array
        // need to catch if values are not between 0 and 100
        let Nxx = value * totalNucleotideContent / 100
        let valuesGtrNxx = cumsumNucleotideContent.indices.filter({ cumsumNucleotideContent[$0] > Nxx})
        return [valuesGtrNxx[0] + 1, fastaLengths[valuesGtrNxx[0]]]
    }

    func usage() {
       let usageStr = """
          assemblyStats InputFastaFile

          Please provide the fasta file as input

    """
        print(usageStr, to: &stderr)
        exit(0)
    }


    let N50out = NXX(value: 50)
    let L50 = N50out[0]
    let N50 = N50out[1]

    let N90out = NXX(value: 90)
    let L90 = N90out[0]
    let N90 = N90out[1]


// PRINT OUTPUT
    print("Number of Scaffolds:\t",numScaffs)
    print("Total Nucleotide content:\t",totalNucleotideContent)
    if numScaffs > 1 {

        if fastas.count > 5 {
            print("Longest Scaffolds:\t",fastas[0].length,fastas[1].length,fastas[2].length,fastas[3].length,fastas[4].length,"\t",fastas[0].def,fastas[1].def,fastas[2].def,fastas[3].def,fastas[4].def)  // longest scaffold is the first scaffold in the sorted Array
            print("Shortest Scaffolds:\t",fastas[fastas.count-1].length,fastas[fastas.count-2].length,fastas[fastas.count-3].length,fastas[fastas.count-4].length,fastas[fastas.count-5].length,"\t", fastas[fastas.count-1].def,fastas[fastas.count-2].def,fastas[fastas.count-3].def,fastas[fastas.count-4].def,fastas[fastas.count-5].def) // shortest scaffold is the last scaffold in the Array
            } else {
            print("Longest Scaffold:\t",fastas[0].length,"\t", fastas[0].def)
            print("Shortest Scaffolds:\t",fastas[fastas.count-1].length,"\t", fastas[fastas.count-1].def)
        }
        print("Mean Scaffold Size:\t",totalNucleotideContent/fastas.count)
        print("Median Scaffold length:\t",calculateMedian(array: fastaLengths, isSorted: true))
        print("N50 Scaffold length:\t",N50)
        print("L50 Scaffold length:\t",L50)
        print("N90 Scaffold length:\t",N90)
        print("L90 Scaffold length:\t",L90)


        print("")
        print("\t","#Scaffs\t%Scaffolds\tNucleotides\t%Nucleotide_Content")
        print("Number of Scaffolds [0-1K) nt:\t",NumScaffsLess1K,"\t",percentOfTotal(count: NumScaffsLess1K,totalCount: fastas.count),"%\t",NcountScaffsLess1K,"\t",percentOfTotal(count: NcountScaffsLess1K,totalCount: totalNucleotideContent),"%")
        print("Number of Scaffolds [1K-10K) nt:\t",NumScaffsGtr1K,"\t",percentOfTotal(count: NumScaffsGtr1K,totalCount: fastas.count),"%\t",NcountScaffsGtr1K,"\t",percentOfTotal(count: NcountScaffsGtr1K,totalCount: totalNucleotideContent),"%")
        print("Number of Scaffolds [10K-100K) nt:\t",NumScaffsGtr10K,"\t",percentOfTotal(count: NumScaffsGtr10K,totalCount: fastas.count),"%\t",NcountScaffsGtr10K,"\t",percentOfTotal(count: NcountScaffsGtr10K,totalCount: totalNucleotideContent),"%")
        print("Number of Scaffolds [100K-1M) nt:\t",NumScaffsGtr100K,"\t",percentOfTotal(count: NumScaffsGtr100K,totalCount: fastas.count),"%\t",NcountScaffsGtr100K,"\t",percentOfTotal(count: NcountScaffsGtr100K,totalCount: totalNucleotideContent),"%")
        print("Number of Scaffolds [1M-10M) nt:\t",NumScaffsGtr1M,"\t",percentOfTotal(count: NumScaffsGtr1M,totalCount: fastas.count),"%\t",NcountScaffsGtr1M,"\t",percentOfTotal(count: NcountScaffsGtr1M,totalCount: totalNucleotideContent),"%")
        print("Number of Scaffolds > 10M nt:\t",NumScaffsGtr10M,"\t",percentOfTotal(count: NumScaffsGtr10M,totalCount: fastas.count),"%\t",NcountScaffsGtr10M,"\t",percentOfTotal(count: NcountScaffsGtr10M,totalCount: totalNucleotideContent),"%")
    } else {
        print("Only a single scaffold, No additional statistics will be calculated")
    }

//EXTENSIONS
//https://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
    extension Sequence where Element: AdditiveArithmetic {
        /// Returns the total sum of all elements in the sequence
        func sum() -> Element { reduce(.zero, +) }
    }
    extension Collection where Element: BinaryInteger {
        /// Returns the average of all elements in the array
        func average() -> Element { isEmpty ? .zero : sum() / Element(count) }
        /// Returns the average of all elements in the array as Floating Point type
        func average<T: FloatingPoint>() -> T { isEmpty ? .zero : T(sum()) / T(count) }
    }

    extension Collection where Element: BinaryFloatingPoint {
        /// Returns the average of all elements in the array
        func average() -> Element { isEmpty ? .zero : Element(sum()) / Element(count) }
    }

    //https://stackoverflow.com/questions/52613600/swift-array-extension-to-replace-value-of-index-n-by-the-sum-of-the-n-previous-v
    extension Array where Element: Numeric {
        func cumsum() -> [Element] {
            return self.reduce([Element](), {acc, element in
                return acc + [(acc.last ?? 0) + element]
            })
        }
    }



// CLASSES
// this is a class to do the line reading.
// taken from https://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift safe syntax 4.2
    final class LineReader {

        let path: String

        init?(path: String) {
            self.path = path
            guard let file = fopen(path, "r") else {
                return nil
            }
            self.file = file
        }
        deinit {
            fclose(file)
        }

        var nextLine: String? {
            var line: UnsafeMutablePointer<CChar>?
            var linecap = 0
            defer {
                free(line)
            }
            let status = getline(&line, &linecap, file)
            guard status > 0, let unwrappedLine = line else {
                return nil
            }
            return String(cString: unwrappedLine)
        }

        private let file: UnsafeMutablePointer<FILE>
    }

    extension LineReader: Sequence {
        func makeIterator() -> AnyIterator<String> {
            return AnyIterator<String> {
                return self.nextLine
            }
        }
    }



// classes to write to stderr and stdout

    final class StandardErrorOutputStream: TextOutputStream {
        func write(_ string: String) {
            FileHandle.standardError.write(Data(string.utf8))
        }
    }
    final class StandardOutputStream: TextOutputStream {
        func write(_ string: String) {
            FileHandle.standardOutput.write(Data(string.utf8))
        }
    }
