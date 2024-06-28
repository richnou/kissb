
import requests

def define_env(env):
    """
    This is the hook for the functions (new form)
    """

    @env.macro
    def latest_dev_release():
        "Get Latest version from S3 release json"

        response = requests.get("https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/dev.json")
        response_json = response.json()
        return response_json["version"]

    @env.macro
    def latest_docker_push(tag = "dev"):
        """"""
        #curl -X GET https://hub.docker.com/v2/repositories/rleys/kissb/tags/dev
        response = requests.get(f"https://hub.docker.com/v2/repositories/rleys/kissb/tags/{tag}")
        response_json = response.json()
        return response_json["last_updated"]