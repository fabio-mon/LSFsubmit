#!/bin/bash

jobid=$1
filelist=$2
CMSSW_VERSION=$3


echo "jobID is " $jobid
echo "Filelist is "$filelist

tar -xzf sandbox.tgz 
files=`grep "^$jobid " $filelist | cut -d ' ' -f 2 | tr '\n' ','`
echo $files
echo "process.source.fileNames = cms.untracked.vstring( [ $files ])" >> pset.py
tail pset.py
echo "========================================"

cd $CMSSW_VERSION/
scram build projectrename
#####try
#scram build --ignore-arch projectrename
eval `scramv1 runtime -sh`
#echo "pwd here: "
#pwd
cd -
#echo "pwd after cd- : "
pwd
echo $jobid $filelist pset.py $CMSSW_BASE
echo "======================================== ls"
ls

echo "doing uname -a"
uname -a 
#echo "======================= ls inside CMSSW"
#ls $CMSSW_VERSION/*/*


#echo "======================= ls inside CMSSW to see inslude RecoEgamma - I"
#ls $CMSSW_VERSION/*/*/*/*/*

#echo "======================= ls inside CMSSW to see inslude RecoEgamma - II"
#ls $CMSSW_VERSION/*/*/*/*/*/*


#echo "======================= ls inside CMSSW to see inslude RecoEgamma - III"
#ls $CMSSW_VERSION/*/*/*/*/*/*/*


#echo "======Catting pset.py to check for errors======="
#cat pset.py

echo "doing which cmsRun "
which cmsRun

echo "======================================== cmsRun"
cmsRun pset.py ||  {
	exitstatus=$?
	echo "[`basename $0`] exitstatus=$exitstatus"
	exit $exitstatus
}
echo "======================================== ls"
ls
echo "======================================== Copy"
./copy config $jobid || exit $((60000+$?))
echo "======================================== END"
#cmsRun pset.py 
