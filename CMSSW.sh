#!/bin/bash

jobid=$1
filelist=$2
CMSSW_VERSION=$3

tar -xzf sandbox.tgz 
files=`grep "^$jobid " $filelist | cut -d ' ' -f 2 | tr '\n' ','`
echo $files
echo "process.source.fileNames = cms.untracked.vstring( [ $files ])" >> pset.py
tail pset.py
echo "========================================"

cd $CMSSW_VERSION/
scram build projectrename
eval `scramv1 runtime -sh`
cd -
echo $jobid $filelist pset.py $CMSSW_BASE
echo "======================================== ls"
ls
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
