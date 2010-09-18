#!/bin/bash
# $1 is Nuclei raw image
# $2 is membrane raw image
# $3 is path to executables (ending with/)
# $4 is cell radius in um




RADIUS=$4
WEIGHTEDRADIUSPLUS=$(echo "$4 * 0.707106781 * 1.3" | bc)
WEIGHTEDRADIUSMINUS=$(echo "$4 * 0.707106781 * 0.7" | bc)
RADIUSMAX=$(echo "$4 * 1.35" | bc)

echo "$WEIGHTEDRADIUSPLUS"
echo "$WEIGHTEDRADIUSMINUS"
echo "$RADIUSMAX"

#first preprocess data
#for the nuclei :
echo "[Preprocess Nuclei]: $1"
echo `time $3cellPreprocess $1 $1_Preprocess_$RADIUS.mha 0 $RADIUS`
#for the membrane :
echo "[Preprocess Membrane]: $2"
echo `time $3cellPreprocess $2 $2_Preprocess_$RADIUS.mha 1 $RADIUS`



#extract foreground
echo "[Extract Foreground]"
echo `time $3cellForeground $1_Preprocess_$RADIUS.mha $2_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha  $1_GaussFit_$RADIUS.mha`

#extract features
echo "[Extract Features Kishore]"
#echo `time ./cellFeature $1_Preprocess_$RADIUS.mha $2_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha  $1_Feature_$RADIUS.mha $1_Distance_$RADIUS.mha`
echo `time $3gradientWeightedDistanceImageFilter $1_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha $1_FeatureMap_$RADIUS.mha  alpha beta`


#extract seeds
echo "[Extract Seeds Kishore]"
echo `time $3seedExtract $1_Foreground_$RADIUS.mha $1_FeatureMap_$RADIUS.mha $1 $1_GaussFit_$RADIUS.mha $1_SeedKishore_$RADIUS.txt $1_NucleiImageKishore_$RADIUS.mha`





#compute features MLOG
echo "[Extract Feature MLOG]"
echo `time $3multiScaleLoGDistanceImageFilter3D $1_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha $1_CompMLOG_$RADIUS.mha $WEIGHTEDRADIUSMINUS $WEIGHTEDRADIUSPLUS 15 2 0`

#echo `time $3multiScaleLoGDistanceImageFilter3D $1_Preprocess_$RADIUS.mha $1_Foreground_$RADIUS.mha $1_CompMLOG_$RADIUS.mha 2.2 4.5 15 2.2 0`

#extract maximas (seeds) MLOG
echo "[Extract MLOG seeds]"
echo `time $3localMaxExtract $1_CompMLOG_$RADIUS.mha $1_Foreground_$RADIUS.mha $1_SeedMLOG_$RADIUS.txt $1_NucleiImageMLOG_$RADIUS.mha 3. 0.02 2500`

#write image for visual comparison
echo "[Write image with MLoG seeds]"
echo `$3blendImageSeeds $1 $1_SeedMLOG_$RADIUS.txt $1_SeedMLOG_$RADIUS.mha`

#write image for visual comparison
echo "[Write image with Kishore seeds]"
echo `$3blendImageSeeds $1 $1_SeedKishore_$RADIUS.txt $1_SeedKishore_$RADIUS.mha`


#compute statistics for both algorithms
echo "[Compute statistics]"
echo `$3validateSeeds $1_Validation.mha $1_SeedKishore_$RADIUS.txt $1_StatKishore_$RADIUS.txt`
echo `$3validateSeeds $1_Validation.mha $1_SeedMLOG_$RADIUS.txt $1_StatMLOG_$RADIUS.txt`


