Universe = vanilla
Executable = mc-minbias-2011-pu.sh
Arguments = 1000 $(Cluster) $(Process)
should_transfer_files = YES
transfer_input_files = MinBias_TuneZ2_7TeV_pythia6_cff.py,start53_lv6a1.tgz
Error = log/mc-minbias-2011-pu_$(Cluster)-$(Process).err
Output = log/mc-minbias-2011-pu_$(Cluster)-$(Process).out
Log = log/mc-minbias-2011-pu_$(Cluster).log
+DESIRED_Sites = "T2_AT_Vienna"
+SingularityImage = "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmsopendata/cmssw_5_3_32:latest"
Queue 100
