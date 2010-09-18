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
echo `time $3BinaryThresholdFiltering $1_Resampled.mha $1_Thresholded.mha 3 255`


#improve membrane
echo "[improve membrane 1]"
echo `time $3multiscalePlateMeasureImageFilter $2_Resampled.mha $2_Improved.mha 0.5 0.5 1 $2_Eigen.mha `

echo "[improve membrane 2]"
echo `time $3membraneVotingField3D $2_Improved.mha $2_Eigen.mha $2_Restored.mha 1`

echo "[Rescale reconstructed membrane]"
echo `time $3RescaleDoubleToUChar $2_Restored.mha $2_Restored.mha`

#distance map of membrane for seeds detection
echo "[distance map]"
echo `time $3DistanceMapCalculation $2_Restored.mha $2_Distance.mha`

echo "[Dilate distance mqp]"
echo `time $3DilateDistanceMap $2_Distance $2_Distance_Dilated`

echo "[local maximas]"
echo `time $3LocalMaximaExtraction $2_Distance.mha $2_Localmax.mha .5 4.5`


echo "[local maximas filtering with nuclei]"
echo `time $3ImageMasking $2_Localmax.mha $1_Thresholded.mha $2_localmaxFiltNuc.mha`

#echo "[Seed grouping]"
#echo `time $3SeedsGrouping $2_localmaxFiltNuc.mha $2_SeedNew.mha $NUCLEIDIAMETER`




#write image for visual comparison
#echo "[Write image with New method seeds]"
#echo `$3blendImageSeeds $1 $1_SeedNew_$RADIUS.txt $1_SeedNew_Blended_$RADIUS.mha`

#write image for visual comparison
#echo "[Write image with Kishore seeds]"
#echo `$3blendImageSeeds $1 $1_SeedKishore_$RADIUS.txt $1_SeedKishore_$RADIUS.mha`


#compute statistics for both algorithms
#echo "[Compute statistics]"
#echo `$3validateSeeds $1_Validation.mha $1_SeedKishore_$RADIUS.txt $1_StatKishore_$RADIUS.txt`
#echo `$3validateSeeds $1_Validation.mha $1_SeedMLOG_$RADIUS.txt $1_StatMLOG_$RADIUS.txt`


