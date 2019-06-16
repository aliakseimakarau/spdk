#!/usr/bin/env bash

testdir=$(readlink -f $(dirname $0))
rootdir=$(readlink -f $testdir/../..)
source $rootdir/test/common/autotest_common.sh
source $rootdir/test/spdkcli/common.sh

MATCH_FILE="spdkcli_pmem.test"
SPDKCLI_BRANCH="/bdevs/pmemblk"

timing_enter spdkcli_pmem
trap 'on_error_exit;' ERR

timing_enter run_spdk_tgt
run_spdk_tgt
timing_exit run_spdk_tgt

timing_enter spdkcli_create_pmem_config
$spdkcli_job "'/bdevs/pmemblk create_pmem_pool /tmp/sample_pmem0 32 512' '' True
'/bdevs/pmemblk create /tmp/sample_pmem0 pmem_bdev0' 'pmem_bdev0' True
'/bdevs/pmemblk create_pmem_pool /tmp/sample_pmem1 32 512' '' True
'/bdevs/pmemblk create /tmp/sample_pmem1 pmem_bdev1' 'pmem_bdev1' True
"
timing_exit spdkcli_create_pmem_config

timing_enter spdkcli_check_match
check_match
timing_exit spdkcli_check_match

timing_enter spdkcli_clear_pmem_config
$spdkcli_job "'/bdevs/pmemblk delete pmem_bdev0' 'pmem_bdev0'
'/bdevs/pmemblk delete_pmem_pool /tmp/sample_pmem0' ''
'/bdevs/pmemblk delete_all' 'pmem_bdev1'
'/bdevs/pmemblk delete_pmem_pool /tmp/sample_pmem1' ''
"
rm -f /tmp/sample_pmem
timing_exit spdkcli_clear_pmem_config

killprocess $spdk_tgt_pid
timing_exit spdkcli_pmem
report_test_completion spdk_cli
