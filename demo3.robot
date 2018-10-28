# ONIC 2018 Demo2: Use genie and parse config
# ===========================================================


*** Settings ***
Library        Collections

Library        ats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library        unicon.robot.UniconRobot


*** Variables ***
# Defining variables that can be used elsewhere in the test data.
# ${testbed}     /genie_tests/default_testbed.yaml
${testbed}     default_testbed.yaml


*** TestCases ***
# Creating testcases using available Genie, PyATS & Unicon keywords

# Connect to devices using CLI
UUT デバイスに接続
    use genie testbed "${testbed}"
    connect to devices "ios1"
    connect to devices "nso"


# Go to Jupyter Notebook
