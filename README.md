# Code4Good - Hackathon 2017
This repository is meant for the health case (stress prevention). It provides some basic code to get started with consuming the Muse and Lifetracker (heartrate) data. It utilizes an iOS app that connects to the devices via bluetooth (BLE) and sends this information to SCP using websockets. For prototyping purposes a lightweight java websocket proxy is provided as well. Which can be deployed to a SCP java compute unit and sends all data received from a websocket client to all other clients connected to the websocket proxy. 

Please use the code at your own risk and as mentioned it is very basic, so it is only to help you get started. 

Good luck!