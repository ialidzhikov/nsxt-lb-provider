#!/bin/bash
#
# Copyright (c) 2019 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e

DIRNAME="$(echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
source "$DIRNAME/common.sh"

header_text "Check"

go install -mod=vendor golang.org/x/lint/golint

export GOFLAGS=-mod=vendor

###############################################################################
PACKAGES="$(go list -e ./... | grep -vE '/vendor/')"
LINT_FOLDERS="$(echo ${PACKAGES} | sed "s|github.com/gardener/nsxt-lb-provider|.|g")"

# Execute static code checks.
echo "Executing go vet"
go vet ${PACKAGES}

# Execute lint checks.
echo "Executing golint"
for package in ${LINT_FOLDERS}; do
    golint -set_exit_status $(find $package -maxdepth 1 -name "*.go" | grep -vE 'zz_generated|_test.go')
done


echo "Checking for format issues with gofmt"
unformatted_files="$(gofmt -l ./cmd ./pkg)"
if [[ "$unformatted_files" ]]; then
    echo "Unformatted files detected:"
    echo "$unformatted_files"
    exit 1
fi

echo "All checks successful"
