{{/*

 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "superset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "superset.fullname" -}}
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
{{- define "superset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "superset-bootstrap" }}
#!/bin/sh

pip install {{ range .Values.additionalRequirements }}{{ . }} {{ end }}

{{ end -}}

{{- define "superset-config" }}
import os
import flask
from flask import request, g

from cachelib.redis import RedisCache
from celery.schedules import crontab
from custom_security_manager import CustomSecurityManager
CUSTOM_SECURITY_MANAGER = CustomSecurityManager
from superset.typing import CacheConfig

REDIS_CELERY_DB = os.environ.get("REDIS_CELERY_DB", 4)
REDIS_RESULTS_DB = os.environ.get("REDIS_RESULTS_DB", 5)
REDIS_CACHE_DB = os.environ.get("REDIS_CACHE_DB", 6)

FEATURE_FLAGS = {
    "THUMBNAILS" : True,
    "ALERT_REPORTS": True,
    "LISTVIEWS_DEFAULT_CARD_VIEW" : True,
    "GLOBAL_ASYNC_QUERIES" : False,
    "CLIENT_CACHE": False,
    "DASHBOARD_CACHE": True,
    "ENABLE_TEMPLATE_PROCESSING": False,
}

# Console Log Settings
LOG_FORMAT = "%(asctime)s:%(levelname)s:%(name)s:%(message)s"
LOG_LEVEL = "ERROR"

SUPERSET_WEBSERVER_TIMEOUT = 120
SQLLAB_TIMEOUT = 60
ENABLE_TIME_ROTATE = True
ENABLE_SCHEDULED_EMAIL_REPORTS = True

def env(key, default=None):
    return os.getenv(key, default)

SCHEDULED_EMAIL_DEBUG_MODE = False
ENABLE_TIME_ROTATE = True
ENABLE_SCHEDULED_EMAIL_REPORTS = True
EMAIL_NOTIFICATIONS = True
SMTP_HOST = "smtp.gmail.com"
SMTP_STARTTLS = True
SMTP_SSL = False
SMTP_USER = os.environ.get("SMTP_USER")
SMTP_PORT = 587
SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD")
SMTP_MAIL_FROM = os.environ.get("SMTP_MAIL_FROM")
EMAIL_REPORTS_USER = "admin"

MAPBOX_API_KEY = env('MAPBOX_API_KEY', '')
DATA_CACHE_CONFIG: CacheConfig = {
      'CACHE_TYPE': 'redis',
      'CACHE_DEFAULT_TIMEOUT': 3*60*60,
      'CACHE_KEY_PREFIX': 'superset_data_',
      'CACHE_REDIS_URL': f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/{REDIS_CACHE_DB}"
}

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{env('DB_USER')}:{env('DB_PASS')}@{env('DB_HOST')}:{env('DB_PORT')}/{env('DB_NAME')}"
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = env('SECRET_KEY', 'thisISaSECRET_1234')

# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = True
# Add endpoints that need to be exempt from CSRF protection
WTF_CSRF_EXEMPT_LIST = []
# A CSRF token that expires in 1 year
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

GLOBAL_ASYNC_QUERIES_REDIS_CONFIG = {
    "port": env('REDIS_PORT'),
    "host": env('REDIS_HOST'),
    "db": 7,
}
GLOBAL_ASYNC_QUERIES_REDIS_STREAM_PREFIX = "async-events-"
GLOBAL_ASYNC_QUERIES_REDIS_STREAM_LIMIT = 1000
GLOBAL_ASYNC_QUERIES_REDIS_STREAM_LIMIT_FIREHOSE = 1000000
GLOBAL_ASYNC_QUERIES_JWT_COOKIE_NAME = "943njnfdk9gengnvdfmfdkkg9d0kgernkgnrrokvkdpfognermlgkekkgwerewwebwekrwnjnk0dfkvlerlmerondnvkjdnfknvjdfoijoiger"
GLOBAL_ASYNC_QUERIES_JWT_COOKIE_SECURE = False
GLOBAL_ASYNC_QUERIES_JWT_SECRET = "test-secret-change-me"
GLOBAL_ASYNC_QUERIES_TRANSPORT = "polling"

class CeleryConfig(object):
    BROKER_URL = f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/{REDIS_CELERY_DB}"
    CELERY_IMPORTS = ("superset.sql_lab","superset.tasks", "superset.tasks.thumbnails")
    CELERY_RESULT_BACKEND = f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/{REDIS_RESULTS_DB}"
    CELERYD_LOG_LEVEL = 'DEBUG'
    CELERYD_PREFETCH_MULTIPLIER = 10
    CELERY_ACKS_LATE = True
    CELERY_ANNOTATIONS = {
        'sql_lab.get_sql_results': {
            'rate_limit': '100/s',
        },
        'email_reports.send': {
            'rate_limit': '1/s',
            'time_limit': 120,
            'soft_time_limit': 150,
            'ignore_result': True,
        },
    }
    CELERYBEAT_SCHEDULE = {
        'email_reports.schedule_hourly': {
            'task': 'email_reports.schedule_hourly',
            'schedule': crontab(minute=1, hour='*'),
        },
        'alerts.schedule_check': {
            'task': 'alerts.schedule_check',
            'schedule': crontab(minute='*', hour='*'),
        },
        'reports.scheduler': {
            'task': 'reports.scheduler',
            'schedule': crontab(minute='*', hour='*'),
        },
        'reports.prune_log': {
            'task': 'reports.prune_log',
            'schedule': crontab(minute=0, hour=0),
        },
        'cache-warmup-hourly': {
             'task': 'cache-warmup',
             'schedule': crontab(minute='*/30', hour='*'),
              'kwargs': {
                 'strategy_name': 'top_n_dashboards',
                 'top_n': 10,
                 'since': '7 days ago',
             },
        },
    }

CELERY_CONFIG = CeleryConfig

RESULTS_BACKEND = RedisCache(
      host=env('REDIS_HOST'),
      port=env('REDIS_PORT'),
      key_prefix='superset_results'
)

THUMBNAIL_SELENIUM_USER = "admin"
THUMBNAIL_CACHE_CONFIG: CacheConfig = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 15*60,
    'CACHE_KEY_PREFIX': 'thumbnail_',
    'CACHE_NO_NULL_WARNING': True,
    'CACHE_REDIS_URL': f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/{REDIS_CACHE_DB}"
}

WEBDRIVER_TYPE= "chrome"
# for older versions this was  EMAIL_REPORTS_WEBDRIVER = "chrome"
WEBDRIVER_OPTION_ARGS = [
        "--force-device-scale-factor=2.0",
        "--high-dpi-support=2.0",
        "--headless",
        "--disable-gpu",
        "--disable-dev-shm-usage",
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-extensions",
        ]
{{- end }}