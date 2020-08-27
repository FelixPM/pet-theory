gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter
gcloud beta run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region us-central1 \
  --no-allow-unauthenticated
SERVICE_URL=$(gcloud beta run services describe pdf-converter --platform managed --region us-central1 --format="value(status.url)")
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-upload
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-processed
gsutil notification create -t new-doc -f json -e OBJECT_FINALIZE gs://$GOOGLE_CLOUD_PROJECT-upload
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"
gcloud beta run services add-iam-policy-binding pdf-converter --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --platform managed --region us-central1
