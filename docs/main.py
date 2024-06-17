
import requests

def define_env(env):
    """
    This is the hook for the functions (new form)
    """

    @env.macro
    def price(unit_price, no):
        "Calculate price"
        return unit_price * no

    @env.macro
    def latest_dev_release():
        "Calculate price"

        response = requests.get("https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/dev.json")
        response_json = response.json()
        return response_json["version"]