# Deploy disBalacer on GCP Cloud Run
Create Container Instances with disBalacer Liberator on GCP Cloud Run

## General preparation
- Create  Google Cloud Account https://console.cloud.google.com/freetrial/signup/tos
- Create new project:
    - In navigation menu go to **IAM & Admin -> Manage resources**
    - Click **Create Project**, name the project as **disliberator** & click Crate
    - Copy the ID of the project & save it. It will be used later as value <PROJECT_ID>

- Enable Artifact Registry API for the project https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com?project=<PROJECT_ID>

- Install Docker Desktop on Windows https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe (guide - https://docs.docker.com/desktop/windows/install/)
    - Enable the WSL 2 feature on Windows. For detailed instructions, refer to the Microsoft documentation.
    - Enable in the BIOS settings BIOS-level hardware virtualization support.

- Install Google Cloud CLI https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe

- Ensure Docker Desktop is running


## Prepare container
- Clone this repo
` git clone https://github.com/UnitybaseExplorer/liberator-cloud-run.git`

- Run Google Cloud Tools for PowerShell (Windows) & cd to cloned repo
`cd full/path-to-cloned-repo/liberator-cloud-run`

- Create project & artifacts repo, build & push container to it:
    - `$project_id="<PROJECT_ID>"` (replace <PROJECT_ID> with ID of the project created earlier)
    - `gcloud artifacts repositories create $project_id-repo --repository-format=docker --location=us-central1 --description="Docker $project_id repository"`
    - `docker build -t us-central1-docker.pkg.dev/$project_id/$project_id-repo/liberator:latest .`

- Test container
`docker run --rm -it -p 8080:8080 us-central1-docker.pkg.dev/$project_id/$project_id-repo/liberator`
    Normal output is:
    ```
    > helloworld@1.0.0 start /app
    > node index.js

    helloworld: listening on port 8080
    [timestamp] updating...
    started disbalancer-go-client
    ...
    ```

- Stop container with `Ctl + C`

- Push image to artifacts repo
`gcloud auth configure-docker us-central1-docker.pkg.dev`
`docker push us-central1-docker.pkg.dev/$project_id/$project_id-repo/liberator:latest`


## Deploy / redeploy container instances
- Deploy container instances
`for ($num = 0; $num -le 9; $num++) {gcloud run deploy liberator-service-$num --image us-central1-docker.pkg.dev/$project_id/$project_id-repo/liberator --region europe-west1 --project=$project_id --platform managed --allow-unauthenticated --quiet --min-instances 1 --max-instances=3 --cpu=1 --memory=1Gi}`

## Read logs
`for ($num = 0; $num -le 9; $num++) {Write-Host "liberator-service-$num status:"; gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=liberator-service-$num" --project $project_id --limit 10 --flatten textPayload --format=list}`