# gitops-picard

Repo to maintain the Picard demo environment.

Make sure to specify the Github action secrets for Spectro Cloud in Github Settings -> Secrets:

    SC_HOST: {{ The Spectro Cloud API endpoint, e.g: api.spectrocloud.com }}
    SC_USERNAME: {{ Spectro Cloud user / service account username }}
    SC_PASSWORD: {{ Spectro Cloud user / service account password }}
    SC_PROJECT_NAME: {{ Spectro Cloud Project name, e.g: Default }}

The `.github/workflows` directory contains Github Action Workflow to show the plan.

Either use Concourse or Github Action to also apply the changes. Currently this demo env is using GitHub Action.

