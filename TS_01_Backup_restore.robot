*** Settings ***
Library     SeleniumLibrary
Library     SSHLibrary
Library     String

#Suite Setup     Run Keyword     Enable Root Access    ${avamar_ip}     admin     ${avamar_password}

Resource     RS_Sanity-test.robot
Resource     %{ENV_ROBOT_PATH}/keyword/install/install.robot
Library      %{ENV_ROBOT_PATH}/lib/InstallUtilityLibrary.py

*** Variables ***


*** Test Cases ***

Dpnctl_status
          [Documentation]      Verify the dpnctl status
          [Tags]    status
#          Enable Root Access    ${avamar_ip}     admin     ${avamar_password}
          ${index}     open connection    ${avamar_ip}
          Login           admin     ${avamar_password}
          ${output}    ${rc}    Execute Command    dpnctl status 2>&1    return_stdout=True    return_rc=True
          Log    ${output}
          Should Contain    ${output}    gsan status: up
          Should Contain    ${output}    MCS status: up
          Should Contain    ${output}    emt status: up
          Should Contain    ${output}    avinstaller status: up
          Should Contain    ${output}    ddrmaint-service status: up
          ${ese_status}     run keyword and return status    Should Contain    ${output}    ESE status: up
          ${connectemc_status}     run keyword and return status    Should Contain    ${output}    ConnectEMC status: up
          should be true     ${ese_status} or ${connectemc_status}
          log to console    GSAN, MCS, EMT, avinstaller, ddrmaint, and all services are up and running
          close connection

Install_Avamar_Client
         [Documentation]     Add client
         [Tags]     client
         open connection     ${client_ip}
         Login     root     ${client_password}
         ${output}=     Execute command    rpm -e AvamarClient
         execute command     rm AvamarClient*
         ${hyphen_version}     convert_to_hyphen_version   ${client_version}
         execute command    wget http://antimatter.asl.lab.emc.com/pretest/v${client_version}/SLES11_64/AvamarClient-linux-sles11-x86_64-${hyphen_version}.rpm
         ${output}=     execute command    rpm -ivh AvamarClient-linux-sles11-x86_64-${hyphen_version}.rpm
         sleep     5s
         Log    ${output}
         should contain     ${output}     Installation complete
         write     /usr/local/avamar/bin/avregister
         ${output}     read until    Enter the Administrator server addres
         write    ${avamar_ip}
         ${output}      read until    Enter the Avamar server domain [clients]:
         write     clients
         sleep     10s
         ${output}     read
         FOR    ${i}     IN RANGE    12
            ${status}    run keyword and return status     should contain     ${output}       Registration Complete.
            exit for loop if     ${status}
            sleep     5s
            ${output}     read
         END
         log to console     The Linux client has successfully added to the Avamar server - ${avamar_ip}.
         close connection

Backup_on_Avamar
        [Documentation]    Perform backup via MCCLI
        [Tags]      gsan
        open connection     ${avamar_ip}
        login     root      ${avamar_password}
        ${client_name}     execute command      mccli client show --domain=/clients | awk 'NR==4{print $1}'
        ${output}=  Execute Command    mccli client backup-target --name=/clients/${client_name} --target=${backup_data} --plugin=1001
        sleep     10s
        ${event_code}=     get substring     ${output}      2     7
        should be equal     ${event_code}    22305
        ${line}=     get line    ${output}     4
        ${list}=     split string    ${line}
        ${activity_id}=    set variable      ${list}[1]
        Log     ${activity_id}
        ${output}=     execute command     mccli activity show --id=${activity_id}
        ${line}=     get line     ${output}      3
        ${list}=     split string    ${line}
        should be equal     ${list}[1]      Completed
        ${output1}      execute command     mccli backup show --name=${client_name} --domain=/clients --verbose | awk 'NR==4{print $19}'
        ${output2}      execute command     mccli backup show --name=${client_name} --domain=/clients --verbose | awk 'NR==4{print $27}'
        ${status1}     run keyword and return status     should be equal     ${output1}     Avamar
        ${status2}     run keyword and return status     should be equal     ${output2}     Avamar
        should be true     ${status1} or ${status2}
        log to console     Backup is successful on Avamar
        close connection

Restore_from_Avamar
       [Documentation]    Perform restore via MCCLI
       [Tags]      gsan
       open connection    ${avamar_ip}
       login     root     ${avamar_password}
       ${client_name}     execute command      mccli client show --domain=/clients | awk 'NR==4{print $1}'
       ${output}=    execute command    mccli backup show --name=${client_name} --domain=/clients
       sleep    5s
       ${line}=     get line    ${output}     3
       ${list}=     split string    ${line}
       ${output}=    execute command    mccli backup restore --name=${client_name} --domain=/clients --labelNum=${list}[3] --plugin=1001
       sleep    5s
       ${event_code}=     get substring     ${output}      2     7
       should be equal     ${event_code}    22312
       ${line}=     get line    ${output}     4
       ${list}=     split string    ${line}
       ${activity_id}=    set variable      ${list}[1]
       Log     ${activity_id}
       ${output}=     execute command     mccli activity show --id=${activity_id}
       ${line}=     get line     ${output}      3
       ${list}=     split string    ${line}
       should be equal     ${list}[1]      Completed
       log to console      Restore successful
       close connection
