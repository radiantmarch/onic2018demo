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
    connect to devices "ios2"
    connect to devices "nxos3"

Execute and parse "show bgp all neighbor" on IOS-XE
    ${output}=  parse "genie.libs.parser.show_bgp.ShowBgpAllNeighbors" on device "ios1"

    ${json}=            evaluate    ast.literal_eval('''${output}''')       ast
    ${json_str}=        evaluate    json.dumps(${json})                     json
    log to console      \nOriginal JSON\n${json_str}
    Log                 ${json_str}

    log to console      \nNeighbors List\n&{json}[list_of_neighbors]
    Log                 &{json}[list_of_neighbors]

    ${num_neighbor}=    Get Length  &{json}[list_of_neighbors]
    Should Be Equal As Strings     ${num_neighbor}     2


#
# execute and parse "show ip ospf neighbors detail" on IOS-XE
#     ${output}=  parse "genie.libs.parser.show_ospf.ShowIpOspfNeighborDetail" on device "uut"

#     ${json}=            evaluate    ast.literal_eval('''${output}''')       ast
#     ${json_str}=        evaluate    json.dumps(${json})                     json
#     log to console      \nOriginal JSON\n${json_str}
#     Log                 ${json_str}

#     # Should Contain  "${output}"     192.168.0.2
