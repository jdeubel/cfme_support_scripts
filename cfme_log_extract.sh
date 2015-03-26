#!/bin/bash
for i in $(ls production* | grep "gz$"); do gunzip $i; done; cat production.log* >> production_full.log
for i in $(ls evm* | grep "gz$"); do gunzip $i; done; cat evm.log* >> evm_full.log
for i in $(ls automation* | grep "gz$"); do gunzip $i; done; cat automation.log* >> automation_full.log
