import os
import json
import time
import requests

while True:

    for file in os.listdir("envs"):

        path = f"envs/{file}"

        with open(path) as f:
            data = json.load(f)

        env_id = data["id"]

        url = f"http://localhost/{env_id}/health"

        start = time.time()

        try:
            r = requests.get(url, timeout=5)

            latency = time.time() - start

            os.makedirs(f"logs/{env_id}", exist_ok=True)

            with open(f"logs/{env_id}/health.log", "a") as log:
                log.write(f"{time.time()} {r.status_code} {latency}\n")

        except Exception:
            os.makedirs(f"logs/{env_id}", exist_ok=True)

            with open(f"logs/{env_id}/health.log", "a") as log:
                log.write(f"{time.time()} FAILED\n")

    time.sleep(30)
