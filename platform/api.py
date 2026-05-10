from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route("/envs", methods=["POST"])
def create_env():

    data = request.json

    name = data.get("name")
    ttl = data.get("ttl", 1800)

    result = subprocess.getoutput(
        f"./platform/create_env.sh {name} {ttl}"
    )

    return jsonify({"result": result})

@app.route("/envs", methods=["GET"])
def list_envs():

    return jsonify(os.listdir("envs"))

app.run(host="0.0.0.0", port=8000)
