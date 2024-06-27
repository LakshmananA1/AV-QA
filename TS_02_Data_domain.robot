*** Settings ***

Resource      RS_Sanity-test.robot

Library     SSHLibrary
Library     String

*** Test Cases ***

Add_DD
      [Documentation]     Adding DD to the Avamar server
      [Tags]     dd
      open connection     ${avamar_ip}
      login     root     ${avamar_password}
      ${count}    execute command      mccli dd show-prop | awk 'NR==4{print $1}' | wc -w
      sleep    10s
      run keyword if    ${count}==0     Add_Data_Domain
      ...     ELSE     return_existing_dd
      close connection

Backup_on_DD
        [Documentation]    Perform backup via MCCLI on DD
        [Tags]     dd
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
        ${output1}      execute command     mccli backup show --name=${client_name} --domain=/clients --verbose | awk 'NR==4{print $21}'
        ${output2}      execute command     mccli backup show --name=${client_name} --domain=/clients --verbose | awk 'NR==4{print $29}'
        ${status1}     run keyword and return status     should be equal     ${output1}     ${dd_ip}
        ${status2}     run keyword and return status     should be equal     ${output2}     ${dd_ip}
        should be true     ${status1} or ${status2}
        log to console     Backup is successful on DD - ${dd_ip}
        close connection

Restore_from_DD
       [Documentation]    Perform restore via MCCLI
       [Tags]      dd
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

Delete_DD
      [Documentation]     Delete or remove data domain system from Avamar
      [Tags]     del_dd      dd
      open connection     ${avamar_ip}
      login     root      ${avamar_password}
      ${output}=      execute command    mccli dd delete --name=${dd_ip} --force
      sleep     15s
      ${event_code}=      get substring     ${output}     2      7
      should be equal     ${event_code}      30936
      should contain     ${output}      Deleted Data Domain system
      Log to console     Data Domain system deleted successfully


*** Keywords ***

Add_Data_Domain
      ${output}=      execute command     mccli dd add --name=${dd_ip} --disable-credential=true --max-streams=20 --password=${dd_password} --password-confirm=${dd_password} --rw-community=avamar --user-name=${dd_username} --default-storage=true --force
      sleep     150s
      ${event_code}=     get substring    ${output}      2     7
      should be equal    ${event_code}      31004
      should contain     ${output}      Data Domain system added
      ${version}=     execute command    mccli dd show-prop | awk 'NR==4{print $19}'
      Log to console     Data Domain system added successfully

Return_existing_dd
      ${ip_addr}=     execute command    mccli dd show-prop | awk 'NR==4{print $1}'
      ${version}=     execute command    mccli dd show-prop | awk 'NR==4{print $19}'
      log to console     Data Domain system already added.