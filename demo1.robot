# ONIC 2018 Demo1: Connect to device and execute commands and config
# ===========================================================


*** Settings ***
Library        Collections

Library        ats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library        unicon.robot.UniconRobot


*** Variables ***
# Defining variables that can be used elsewhere in the test data.
${testbed}     default_testbed.yaml


*** TestCases ***
# Creating testcases using available Genie, PyATS & Unicon keywords

# Connect to devices using CLI
UUT デバイスに接続
    use genie testbed "${testbed}"
    connect to devices "ios1"
    connect to devices "ios2"

# Execute "show ip route" on ios1
Execute "show ip route" on device ios1
    ${output}=  execute "show ip route" on device "ios1"
    Should Contain  "${output}"     192.168.0.2

# shutdown interface on ios2
Shutdown loopback interface on device ios2
    configure "interface loopback 0\n shutdown" on device "ios2"

# Execute "show ip route" on ios1
Execute "show ip route" on device ios1 after trigger
    Log To Console    Waiting 10 seconds for routing convergence...
    Sleep   10s

    ${output}=  execute "show ip route" on device "ios1"
    Should Not Contain  "${output}"     192.168.0.2

# restore interface on ios2
Restore loopback interface on device
    configure "interface loopback 0\n no shutdown" on device "ios2"
