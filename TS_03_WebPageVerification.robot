*** Settings ***

Library     SeleniumLibrary
Library     Collections

Resource    RS_Sanity-test.robot
Resource    ../../keyword/web/RS_common_gui_keywords.robot

Suite Teardown    Run Keyword     close all browsers

*** Test Cases ***
AVIPage
    [Documentation]    Login to the AVI page
    ...                Navigate to History tab
    ...                Logout
    [Tags]      AVI      web
    open browser     https://${avamar_ip}/avi     ${browser_type}
    maximize browser window
    click button    ${ADVANCED_BUTTON}
    click link     ${PROCEED_LINK}
    Login_to_Avamar     ${avamar_password}
    wait until element is visible     ${AREA_PRESSED}     timeout=20s
    click element     ${HISTORY}
    capture page screenshot
    log to console     AVI page is accessible
    Logout

AUIPage
    [Documentation]    Login to the AUI page
    ...                AVI_Logout
    [Tags]     AUI     web
    execute javascript    window.open('https://${avamar_ip}/aui', '_blank')
    select window    new
    Login_to_Avamar     ${avamar_password}
    wait until element is visible    ${AUI_DASHBOARD}     timeout=20s
    page should contain element     ${EXPAND}
    sleep    2s
    click element    ${EXPAND}
    click element     ${ACTIVITY}
    capture page screenshot
    log to console     AUI page is accessible
    Logout


DTLTPage
    [Documentation]    Open DTLT Page
    [Tags]     DTLT     web
    execute javascript    window.open('https://${avamar_ip}/', '_blank')
    switch window    new
    switch window    main
    ${titles}     create list
    ${windows}=    Get Window Handles
    FOR    ${window}     IN    @{windows}
       switch window     locator=${window}
       ${output}     get title
       append to list    ${titles}     ${output}
       capture page screenshot
    END
    Log     ${titles}
    wait until page contains     ${GET_AVAMAR_SOFTWARE}      timeout=20s
    capture page screenshot
    log to console     DTLT page is accessible

ACMPage
    [Documentation]    Login to ACM Page
    ...                Logout
    [Tags]     ACM      web
    execute javascript     window.open('https://${avamar_ip}/aam', '_blank')
    switch window     new
    Login_to_Avamar      ${avamar_password}
    wait until page contains     ${SERVER_SUMMARY}       timeout=20s
    page should contain     ${AVAMAR_CLIENT_MANAGER}
    click element      ${ACM_DASHBOARD}
    wait until page does not contain     ${LOADING_MSG}
    capture page screenshot
    log to console     ACM page is accessible
#    ACM_Logout

EagleeyePage
    [Documentation]    Login to Eagleeye Page
    ...                Logout
    [Tags]     Eagleeye      web
    execute javascript    window.open('https://${avamar_ip}/eagleeye', '_blank')
    switch window    new
    Login_to_Avamar     ${avamar_password}
    wait until page contains    ${POLICY_OVERVIEW}      timeout=20s
    page should contain    ${FITNESS_ANALYZER}
    click element     ${EE_BACKUP}
    sleep    3s
    capture page screenshot
    log to console     Eagleeye page is accessible
    EE_Logout



