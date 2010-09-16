#!/bin/bash
# $1 is Nuclei raw image
# $2 is membrane raw image
# $3 is path to executables (ending with/)
# $4 is cell radius in um




RADIUS=$4
NUCLEIDIAMETER=$(echo "$4 * 2" | bc)

echo "$NUCLEIDIAMETER"

#first preprocess data
#for the nuclei :
echo "[Median Nuclei radisu 1.5]: $1"
echo `time $3./MedianFiltering $1 $1_Median.mha 1.2`
#for the membrane :
echo "[Median Membrane radius 0.7]: $2"
echo `time $3MedianFiltering $2 $2_Median.mha 0.7`



#resample nuclei
echo "[Resample nuclei]"
echo `time $3ResampleImage  $1_Median.mha $1_Resampled.mha 1 255 5`

#resample membrane
echo "[Resample membrane]"
echo `time $3ResampleImage  $2_Median.mha $2_Resampled.mha 5 255 5`


#threshold nuclei for filtering seeds
echo "[threshold Nuclei]"
echo `time $3BinaryThresholdFiltering $1_Resampled.mha $1_Thresholded.mha 2 255`


#improve membrane
echo "[improve membrane 1]"
echo `time $3multiscalePlateMeasureImageFilter $2_Resampled.mha $2_Improved.mha 0.5 0.5 0`

echo "[improve membrane 2]"
echo `time $3membraneVotingField3D $2_Improved.mha $2_eigenMatrix.mha $2_saliency.mha 1`

#distance map of membrane for seeds detection
echo "[distance map]"
echo `time $3DistanceMapCalculation $2_Improved.mha $2_distance.mha`

echo "[local maximas]"
echo `time $3LocalMaximaExtraction $2_distance.mha $2_localmax.mha 4.`


echo "[local maximas filtering with nuclei]"
echo `time $3SeedsFilteringNuclei  $2_localmax.mha $1_Thresholded.mha $2_localmaxFiltNuc.mha`

echo "[Seed grouping]"
echo `time $3SeedsGrouping $2_localmaxFiltNuc.mha $2_FinalSeeds.mha $NUCLEIDIAMETER`


#write image for visual comparison
#echo "[Write image with MLoG seeds]"
#echo `$3blendImageSeeds $1 $1_SeedMLOG_$RADIUS.txt $1_SeedMLOG_$RADIUS.mha`

#write image for visual comparison
#echo "[Write image with Kishore seeds]"
#echo `$3blendImageSeeds $1 $1_SeedKishore_$RADIUS.txt $1_SeedKishore_$RADIUS.mha`


#compute statistics for both algorithms
#echo "[Compute statistics]"
#echo `$3validateSeeds $1_Validation.mha $1_SeedKishore_$RADIUS.txt $1_StatKishore_$RADIUS.txt`
#echo `$3validateSeeds $1_Validation.mha $1_SeedMLOG_$RADIUS.txt $1_StatMLOG_$RADIUS.txt`


