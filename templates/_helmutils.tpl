{{/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
*/}}

{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kudu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kudu.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kudu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate Kudu Masters String
*/}}
{{- define "kudu.gen_kudu_masters" -}}
{{- $master_replicas := .Values.replicas.master | int -}}
{{- $domain_name := .Values.domainName -}}
  {{range $index := until $master_replicas }}{{if ne $index 0}},{{end}}kudu-master-{{ $index }}.kudu-masters.$(NAMESPACE).svc.cluster.local{{end}}
{{- end -}}

{{/*
Generate the maximum number of fail-over pods based on master replicas
Ensures that the number of replicas running is never brought below the number needed for a quorum.
*/}}
{{- define "kudu.max_failovers" -}}
{{- $master_replicas := .Values.replicas.master | int | mul 100 -}}
{{- $master_replicas := 100 | div (100 | sub (2 | div ($master_replicas | add 100))) -}}
{{- printf "%d" $master_replicas -}}
{{- end -}}

{{/*
Generate a comma-separated list of Kudu Master data directories
NOTE: the first directory is for WALs, so start the count at index 1.
*/}}
{{- define "kudu.gen_kudu_master_data_dirs" -}}
{{- $num_dirs := .Values.storage.master.count | int -}}
{{range $index := untilStep 1 $num_dirs 1 -}}{{if ne $index 1}},{{end}}/mnt/disk{{ $index }}{{end}}
{{- end -}}

{{/*
Generate a comma-separated list of Kudu Tablet Server data directories
NOTE: the first directory is for WALs, so start the count at index 1.
*/}}
{{- define "kudu.gen_kudu_tserver_data_dirs" -}}
{{- $num_dirs := .Values.storage.tserver.count | int -}}
{{range $index := untilStep 1 $num_dirs 1 -}}{{if ne $index 1}},{{end}}/mnt/disk{{ $index }}{{end}}
{{- end -}}
