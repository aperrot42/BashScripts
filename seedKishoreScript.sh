#!/bin/bash
echo "Start procedure for getting foreground out of nuclei and membrane image"

RADIUS=$3

#first preprocess data
#for the nuclei :
echo "[Preprocess Nuclei]: $1"
echo `time ./cellPreprocess $1 $1_Preprocess_$RADIUS.mha 0 $RADIUS`
#for the membrane :
echo "[Preprocess Membrane]: $2"
echo `time ./cellPreprocess $2 $2_Preprocess_$RADIUS.mha 1 $RADIUS`

#extract foreground
echo "[Extract Foreground]"
echo `time ./cellForeground $1_Preprocess_$RADIUS.mha $2_Peprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha  $1_GaussFit_$RADIUS.mha`

#extract features
echo "[Extract Features]"
echo `time ./cellFeature $1_Preprocess_$RADIUS.mha $2_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha  $1_Feature_$RADIUS.mha $1_Distance_$RADIUS.mha`

#extract seeds
echo "[Extract Seeds]"
echo `time ./seedExtract $1_Foreground_$RADIUS.mha $1_Feature_$RADIUS.mha $1 $1_Comp_$RADIUS.mha`

