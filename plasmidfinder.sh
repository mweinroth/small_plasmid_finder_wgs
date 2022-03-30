#!/bin/sh

#For identification of known plasmids in short read trimmed data and generation of the report used on 10.133.62.180
#Maggie Weinroth
#2-4-2020

##trimmed files should be named $NAME_1P.fq.gz or _2P

#Controls to change#
#directory with trimmed reads
#load modules#
echo "loading modules..."
module load bwa/0.7.17
module load samtools/1.9

#getting file names USER UPLAOD
samples='2017F'

reference='/home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/reference/all.fasta'
bbmap='/home/maggie.weinroth/tools/bbmap/bbmap'

cd /home/maggie.weinroth/ecoli_evolution/trimmed_libraries


for s in ${samples[@]}; do
    forward=()
    reverse=()
    for f in ./"$s"_*.fq.gz; do
        if [[ $f =~ "_1P" ]]; then
            forward+=("$f")
        elif [[ $f =~ "_2P" ]]; then
            reverse+=("$f")
        fi
    done
            
    if [ ${#forward[@]} != ${#reverse[@]} ] || [ ${#forward[@]} == 0 ]; then
        echo "Sample $s is missing a forward and/or reverse file pair"
    else
        echo "Running $s"
        echo "${forward[@]}"
        echo -e "${reverse[@]}\n"
        for (( idx=0; idx<${#forward[@]}; idx++ )); do
            bwa aln $reference ${forward[$idx]} > /home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${forward[$idx]}.sai
            bwa aln $reference ${reverse[$idx]} > /home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${reverse[$idx]}.sai
            bwa sampe -n 1000 -N 1000 $reference /home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${forward[$idx]}.sai /home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${reverse[$idx]}.sai ${forward[$idx]} ${reverse[$idx]} > /home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${s}.sam
            $bbmap/pileup.sh  in=/home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/intfiles/${s}.sam out=/home/maggie.weinroth/ecoli_evolution/find_plasmids/otherPlasmids/final_count/${s}.count.txt
            echo "Sample $s plasmid count is complete!"
        done
    fi
done

