#!/usr/bin/env bash
ENRICHED_FOLDER=$1
RTTM_FOLDER=$2
SP_FOLDER=$3
SCRIPT_DIR=$(dirname "$0")

ENRICHED_FOLDER="${ENRICHED_FOLDER}/"
RTTM_FOLDER="${RTTM_FOLDER}/"
DIROP_FOLDER="/vagrant/data/WCE_VM_TEMP/"
SP_FOLDER="/vagrant/${SP_FOLDER}/"

mkdir -p ${DIROP_FOLDER}

for en_path in ${ENRICHED_FOLDER}*.txt; do
  curr_id=${en_path##*/}
  curr_id="${curr_id%_enriched.txt}"
  for rttm_path in ${RTTM_FOLDER}*${curr_id}*.rttm; do  
    python $SCRIPT_DIR/combine_rttm_and_enrich.py ${en_path} ${rttm_path} ${SP_FOLDER} ${DIROP_FOLDER}
  done
  python $SCRIPT_DIR/calcAlpha.py ${DIROP_FOLDER} ${curr_id}
done
