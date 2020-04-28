*** Keywords ***
RteCtrl Relay
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrl     /api/v1/gpio/0    ${headers}
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${relay}=    Patch Request    RteCtrl    /api/v1/gpio/0    ${message}    headers=${headers}
    [Return]    ${state}

RteCtrl Power On
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${power}=    Patch Request    RteCtrl    /api/v1/gpio/9    ${message}    headers=${headers}

RteCtrl Power Off
    [Arguments]    ${time}=${5}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${time}
    ${power}=    Patch Request    RteCtrl    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    ${time}s

RteCtrl Reset
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${reset}=    Patch Request    RteCtrl    /api/v1/gpio/8    ${message}    headers=${headers}

RteCtrl Set OC GPIO
    [Arguments]    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high-z'    ${0}
    ...    '${gpio_state}' == 'low'    ${1}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    RteCtrl    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Set GPIO
    [Arguments]    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19}   Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high'    ${1}
    ...    '${gpio_state}' == 'low'    ${0}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    RteCtrl    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Get OC GPIO State
    [Arguments]    ${gpio_no}
    Run Keyword If    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrl     /api/v1/gpio/${gpio_no}    ${headers}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    low
    ...    '${gpio_state}' == '0'    high-z
    [Return]    ${state}

RteCtrl Get GPIO State
    [Arguments]    ${gpio_no}
    Run Keyword If    int(${gpio_no}) != ${0} and (int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19})   Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrl     /api/v1/gpio/${gpio_no}    ${headers}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    high
    ...    '${gpio_state}' == '0'    low
    [Return]    ${state}

REST API Setup
    [Arguments]    ${session_handler}
    RequestsLibrary.Create Session    ${session_handler}    http://${rte_ip}:${http_port}    verify=True
