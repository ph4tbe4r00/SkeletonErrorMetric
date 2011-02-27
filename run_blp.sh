#!/bin/bash
set -e

cat blp_temp_input.txt | ../co_cluster_distrib/src/cocluster_LPR.sh

