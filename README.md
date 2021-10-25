# Trino-GCP
Trino GCP Gracefull Shutdown Instance Groups Autoscaling etc

Gracefull Shutdown Script

Download Script and place on A GCP VM or Airflow Server. chmod file for execution and run with the following parameters.

#Invoke Command ./trino-workers-shutdown-resize.sh 1 SIGNAL-SHUTDOWN group-analytics-trino-worker-group-highmem16 0
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN group-analytics-trino-worker-group-highmem16 0 --Invoke SIGNAL-SHUTDOWN First
#Invoke Command ./trino-workers-shutdown-resize.sh 0 RESIZE group-analytics-trino-worker-group-highmem16 1
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN-RESIZE group-analytics-trino-worker-group-highmem16 1 --Invoke SIGNAL-SHUTDOWN First

I will include Templates and Instance Group Commands and Setup for Trino on Instance Groups Autoscaling at a later date.
