#!/bin/bash

jobid=$1
filelist=$2
CMSSW_VERSION=$3

tar -xzf sandbox.tgz 

cd $CMSSW_VERSION/
scram build projectrename
eval `scramv1 runtime -sh`
cd -

files=`grep "^$jobid " $filelist | cut -d ' ' -f 2 | tr '\n' ','`
echo $files
echo $files | grep -q "root://" && {
	root -l -b -q `echo $files |tr ',' ' ' | tr '"' ' ' ` 2>&1 | tee xrootd_test.log
	grep -q Warning xrootd_test.log && {
		for file in `echo $files | tr ',' ' ' | tr '"' ' '`
		do
			xrdcp -vsN $file . || exit 10
		done
		files=`echo $files | sed 's|".*/|"file:|'`
	}
}
echo $files
echo "process.source.fileNames = cms.untracked.vstring( [ $files ])" >> pset.py
echo "------------------------------"
tail pset.py
echo "========================================"

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
for file in `echo $files | tr '"' ' ' | tr ',' ' ' | sed 's|file:||g`
do
	rm $file
done

echo "======================================== Copy"
./copy config $jobid || exit $((60000+$?))
echo "======================================== END"
#cmsRun pset.py 
