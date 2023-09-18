*** Settings ***
Documentation       Keywords for RTE REST API


*** Keywords ***
RteCtrl Relay
    [Documentation]    Keyword invokes the procedure of switching the RTE relay.
    ${relay}=    GET On Session    RteCtrl    /api/v1/gpio/0
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary    state=${state}    direction=out    time=${0}
    ${relay}=    PATCH On Session    RteCtrl    /api/v1/gpio/0    json=${message}
    RETURN    ${state}

RteCtrl Power On
    [Documentation]    Keyword invokes the procedure of power on the DUT.
    ...    Takes as arguments the time that the power pin
    ...    should be shorted to ground to cause the device to turn on.
    [Arguments]    ${time}=${1}
    ${message}=    Create Dictionary    state=${1}    direction=out    time=${time}
    ${power}=    PATCH On Session    RteCtrl    /api/v1/gpio/9    json=${message}
    Sleep    ${time}s

RteCtrl Power Off
    [Documentation]    Keyword invokes the procedure of power off the DUT.
    ...    Takes as argument the time that the power pin
    ...    should be shorted to ground to cause the device to shut down.
    [Arguments]    ${time}=${5}
    ${message}=    Create Dictionary    state=${1}    direction=out    time=${time}
    ${power}=    PATCH On Session    RteCtrl    /api/v1/gpio/9    json=${message}
    Sleep    ${time}s

RteCtrl Reset
    [Documentation]    Keyword invokes the procedure of resetting the DUT.
    ...    Takes as argument the time that the reset pin
    ...    should be shorted to ground to cause the device resetting.
    [Arguments]    ${time}=${1}
    ${message}=    Create Dictionary    state=${1}    direction=out    time=${time}
    ${reset}=    PATCH On Session    RteCtrl    /api/v1/gpio/8    json=${message}
    Sleep    ${time}s

RteCtrl Set OC GPIO
    [Documentation]    Keyword sets the requested state of requested RTE OC
    ...    GPIO. Takes as argument number of GPIO and requested state.
    [Arguments]    ${gpio_no}    ${gpio_state}
    IF    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}
        Fail    Wrong GPIO number
    END
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high-z'    ${0}
    ...    '${gpio_state}' == 'low'    ${1}
    ${message}=    Create Dictionary    state=${state}    direction=out    time=${0}
    ${response}=    PATCH On Session    RteCtrl    /api/v1/gpio/${gpio_no}    json=${message}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Set GPIO
    [Documentation]    Keyword sets the requested state of requested RTE GPIO.
    ...    Takes as arguments number of GPIO and requested state.
    [Arguments]    ${gpio_no}    ${gpio_state}
    IF    int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19}
        Fail    Wrong GPIO number
    END
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high'    ${1}
    ...    '${gpio_state}' == 'low'    ${0}
    ${message}=    Create Dictionary    state=${state}    direction=out    time=${0}
    ${response}=    PATCH On Session    RteCtrl    /api/v1/gpio/${gpio_no}    json=${message}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Get OC GPIO State
    [Documentation]    Keyword returns the current state of requested RTE OC.
    ...    GPIO. Takes as arguments number of GPIO.
    [Arguments]    ${gpio_no}
    IF    int(${gpio_no}) < ${1} or int(${gpio_no}) > ${12}
        Fail    Wrong GPIO number
    END
    ${relay}=    GET On Session    RteCtrl    /api/v1/gpio/${gpio_no}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    low
    ...    '${gpio_state}' == '0'    high-z
    RETURN    ${state}

RteCtrl Get GPIO State
    [Documentation]    Keyword returns the current state of requested RTE GPIO.
    ...    Takes as arguments number of GPIO.
    [Arguments]    ${gpio_no}
    IF    int(${gpio_no}) != ${0} and (int(${gpio_no}) < ${13} or int(${gpio_no}) > ${19})
        Fail    Wrong GPIO number
    END
    ${relay}=    GET On Session    RteCtrl    /api/v1/gpio/${gpio_no}
    ${gpio_state}=    Evaluate    int((${relay.json()["state"]})%2)
    ${state}=    Set Variable If
    ...    '${gpio_state}' == '1'    high
    ...    '${gpio_state}' == '0'    low
    RETURN    ${state}

RTE REST API Setup
    [Documentation]    Keyword creates HTTP session with the requested RTE.
    ...    Takes as arguments RTE IP and http port.
    [Arguments]    ${rte_ip}    ${rte_http_port}
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    RequestsLibrary.Create Session    RteCtrl    http://${rte_ip}:${rte_http_port}    verify=True    headers=${headers}
