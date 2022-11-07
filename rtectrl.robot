*** Keywords ***
RteCtrl Relay
    [Documentation]    Keyword invokes the procedure of switching the RTE relay.
    ...    Takes as an argument session handler.
    [Arguments]    ${session_handler}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     ${session_handler}     /api/v1/gpio/0    ${headers}
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${relay}=    Patch Request    ${session_handler}    /api/v1/gpio/0    ${message}    headers=${headers}
    [Return]    ${state}

RteCtrl Power On
    [Documentation]    Keyword invokes the procedure of power on the DUT.
    ...    Takes as arguments session handler and the time that the power pin
    ...    should be shorted to ground to cause the device to turn on.
    [Arguments]    ${session_handler}    ${time}=${1}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${time}
    ${power}=    Patch Request    ${session_handler}    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    ${time}s

RteCtrl Power Off
    [Documentation]    Keyword invokes the procedure of power off the DUT.
    ...    Takes as arguments session handler and the time that the power pin
    ...    should be shorted to ground to cause the device to shut down.
    [Arguments]    ${session_handler}    ${time}=${5}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${time}
    ${power}=    Patch Request    ${session_handler}    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    ${time}s

RteCtrl Reset
    [Documentation]    Keyword invokes the procedure of resetting the DUT.
    ...    Takes as arguments session handler and the time that the reset pin
    ...    should be shorted to ground to cause the device resetting.
    [Arguments]    ${session_handler}    ${time}=${1}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${time}
    ${reset}=    Patch Request    ${session_handler}    /api/v1/gpio/8    ${message}    headers=${headers}
    Sleep    ${time}s

RteCtrl Set OC GPIO
    [Documentation]    Keyword sets the requested state of requested RTE OC
    ...    GPIO. Takes as arguments session handler, number of GPIO and
    ...    requested state.
    [Arguments]    ${session_handler}    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high-z'    ${0}
    ...    '${gpio_state}' == 'low'    ${1}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    ${session_handler}    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Set GPIO
    [Documentation]    Keyword sets the requested state of requested RTE GPIO.
    ...    Takes as arguments session handler, number of GPIO and requested
    ...    state.
    [Arguments]    ${session_handler}    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19}   Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high'    ${1}
    ...    '${gpio_state}' == 'low'    ${0}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    ${session_handler}    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Get OC GPIO State
    [Documentation]    Keyword returns the current state of requested RTE OC.
    ...    GPIO. Takes as arguments session handler and number of GPIO.
    [Arguments]    ${session_handler}    ${gpio_no}
    Run Keyword If    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     ${session_handler}     /api/v1/gpio/${gpio_no}    ${headers}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    low
    ...    '${gpio_state}' == '0'    high-z
    [Return]    ${state}

RteCtrl Get GPIO State
    [Documentation]    Keyword returns the current state of requested RTE GPIO.
    ...    Takes as arguments session handler and number of GPIO.
    [Arguments]    ${session_handler}    ${gpio_no}
    Run Keyword If    int(${gpio_no}) != ${0} and (int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19})   Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     ${session_handler}     /api/v1/gpio/${gpio_no}    ${headers}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    high
    ...    '${gpio_state}' == '0'    low
    [Return]    ${state}

RTE REST API Setup
    [Documentation]    Keyword creates HTTP sesion with the requested RTE.
    ...    Takes as arguments session handler, RTE IP and http port.
    [Arguments]    ${session_handler}    ${rte_ip}    ${rte_http_port}
    RequestsLibrary.Create Session    ${session_handler}    http://${rte_ip}:${rte_http_port}    verify=True
