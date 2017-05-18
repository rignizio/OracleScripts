#!/bin/bash

################################
#### PARSE INPUT PARAMETERS ####
################################
function usage()
{
    echo ""
    echo -e "\033[1;37mUSAGE:\033[0m"
    echo -e "       \033[1;37m./execute_oracle_sql_file.sh\033[0m [\033[4moptions\033[0m]"
    echo ""
    echo -e "       \033[41m\033[1;37m-orasid\033[0m [ \033[4mORACLE_SID\033[0m ]"
    echo "              Used to set the ORACLE_SID for processing."
    echo ""
    echo -e "       \033[41m\033[1;37m-all\033[0m"
    echo "              When using the -all option, the sql script will execute on all of the running oracle instances."
    echo "                  CANNOT be used with the -orasid argument."
    echo "                  If -all and -orasid are both passed at the same time, then the -all option is ignored"
    echo ""
    echo -e "       \033[41m\033[1;37m-url\033[0m [ \033[4mBITBUCKET URL TO SQL SCRIPT\033[0m ]"
    echo "              The code.paychex.com bitbucket url to the sql script that will be executed."
    echo ""
    echo -e "\033[1;33mOPTIONAL ARGUMENTS:\033[0m "
    echo -e "       \033[41m\033[1;37m-as_sysdba\033[0m"
    echo "              Execute the sql file as sysdba."
    echo "                  Executes as ops\$oracle by default."
    echo ""
    echo -e "\033[1;37mEXAMPLE 1:\033[0m"
    echo "       ./execute_oracle_sql_file.sh -orasid spdba1 -url 'https://code-api.paychex.com/projects/DBA/repos/sql_repository/browse/database/Information/dbinfo.sql'"
    echo ""
    echo -e "\033[1;37mEXAMPLE 2:\033[0m"
    echo "       ./execute_oracle_sql_file.sh -all -as_sysdba -url 'https://code-api.paychex.com/projects/DBA/repos/sql_repository/browse/counts.sql'"
    echo ""
}

function ora_sid_validator()
{
    INPUT_DB_VAL="${1}"
    ORATAB_ARRAY=( $(cat /etc/oratab | grep -v -E "^#" | grep -v -E "^$" | grep -v -E "^\*" | cut -d ':' -f1 | sort) );

    MATCH_FOUND="FALSE";

    for CUR_SID_EVAL in ${ORATAB_ARRAY[*]}
    do
        if [ "${CUR_SID_EVAL}" = "${INPUT_DB_VAL}" ]
        then
            MATCH_FOUND="TRUE"
            break
        fi
    done

    if [ "${MATCH_FOUND}" = "FALSE" ]; then echo "INVALID SID - ${INPUT_DB_VAL} PROVIDED."; fi
}

for arg
do
    delim=""
    case "$arg" in
    #translate --gnu-long-options to -g (short options)
       -orasid) args="${args}-s ";;
       -all) ALL_ARG_PASSED="TRUE";;
       -url) args="${args}-u ";;
       -as_sysdba) RUN_AS_SYSDBA="TRUE";;
       help) args="${args}-? ";;
       usage) args="${args}-? ";;
       \?) args="${args}-? ";;
       /?) args="${args}-? ";;
       #pass through anything else
       *) [[ "${arg:0:1}" == "-" ]] || delim="\""
           args="${args}${delim}${arg}${delim} ";;
    esac
done

#Reset the positional parameters to the short options
eval set -- $args

while getopts "s:u:?" OPTIONS
do
    case $OPTIONS in
        s ) PASSED_ORACLE_SID=$OPTARG;;
        u ) SQL_FILE_URL=$OPTARG;;
        \? ) usage
            exit 1;;
        * ) usage
            exit 1;;
    esac
done

ALL_PARAMETERS_FOUND="TRUE"
PARAM_PASSED="FALSE"

###############
#SET VARIABLES#
###############
SID_TO_EVAL=$(echo "${PASSED_ORACLE_SID}" | tr "[:upper:]" "[:lower:]" | awk '{gsub(/ /, ""); print}')
if [ "${RUN_AS_SYSDBA}" = "TRUE" ]; then SYSDBA_OPTION="as sysdba"; else SYSDBA_OPTION=""; fi

########################
#### VALIDATE INPUT ####
########################
if [ "${SID_TO_EVAL}" = "" -a "${ALL_ARG_PASSED}" = "" ]
then
    ERROR_MSG=$(echo -e "    One of the following options must passed:\n        \033[41m\033[1;33mORACLE_SID\033[0m parameter must be specified using the \033[41m\033[1;37m-orasid\033[0m option.\n    \033[1;37mOR\033[0m\n        \033[41m\033[1;37m-all\033[0m option must be passed.\n${ERROR_MSG}")
    ALL_PARAMETERS_FOUND="FALSE"
else
    PARAM_PASSED="TRUE"
    # If a SID is provided validate that it's a actual SID found on the server.
    if [ -n "${SID_TO_EVAL}" ]
    then
        CHECK_FOR_VALID_SID=$(ora_sid_validator "${SID_TO_EVAL}")
        if [ "${CHECK_FOR_VALID_SID}" = "INVALID SID - ${SID_TO_EVAL} PROVIDED." ]
        then
            ERROR_MSG=$(echo -e "    ******* ERROR *******\n    INVALID SID: the -orasid parameter passed \"${SID_TO_EVAL}\" was not found in /etc/oratab. Please pass in a valid ORACLE_SID.\n\n${ERROR_MSG}")
    echo "${STRING_TO_LOG}"
    echo ""
    echo ""
            ALL_PARAMETERS_FOUND="FALSE"
        else
            # In the event the -all parameter was provided along with the -orasid parameter, set the ALL_ARG_PASSED to false.
            ALL_ARG_PASSED="FALSE"
        fi
    fi
    # If no SID is provided and ALL_ARG_PASSED is set, then there is no further action needed here.
fi

if [ "${SQL_FILE_URL}" = "" ]
then
    ERROR_MSG=$(echo -e "    ******* ERROR *******\n    BITBUCKET URL TO SQL SCRIPT: parameter must be specified using the -url option.\n\n${ERROR_MSG}")
    ALL_PARAMETERS_FOUND="FALSE"
else
    PARAM_PASSED="TRUE"
    ###############
    #SET VARIABLES#
    ###############
    DECODED_SQL_FILE_URL="$(echo "${SQL_FILE_URL}" | awk '{gsub(/%20/," "); print}')"
    SQL_FILE_NAME=$(basename "${DECODED_SQL_FILE_URL}")
    PROC_SQL_FILE_NM=$(echo "${SQL_FILE_NAME}" | awk '{gsub(/ /,"_"); print}')
    SQL_TO_EXECUTE="/tmp/${PROC_SQL_FILE_NM}"

    # Download the file from Bitbucket/code.paychex.com
    su - oracle -c "curl -s -o ${SQL_TO_EXECUTE} \"${SQL_FILE_URL}?raw\""

    # Verify that the file was downloaded.
    if [ ! -e ${SQL_TO_EXECUTE} ]
    then
        ERROR_MSG=$(echo -e "    ******* ERROR *******\n    INVALID URL - Unable to reach '${DECODED_SQL_FILE_URL}'\n    Confirm the URL being passed is correct\n        TROUBLESHOOTING NOTE: When passing the -url option try placing the address in single quotes.\n\n${ERROR_MSG}")
        ALL_PARAMETERS_FOUND="FALSE"
    else
        # If there are errors then the program will exit out, so delete the file that was downloaded.
        if [ "${ALL_PARAMETERS_FOUND}" = "FALSE" ]
        then
            rm -f ${SQL_TO_EXECUTE}
        fi
    fi
fi

if [ "${ALL_PARAMETERS_FOUND}" = "FALSE" ]
then
    if [ "${PARAM_PASSED}" = "TRUE" ]
    then
        echo ""
        echo "${ERROR_MSG}"
        echo ""
    else
        echo ""
        echo -e "\033[41m\033[1;33mNo Paramters Were Given. Displaying Help Page....\033[0m"
        echo ""
        sleep 1
        usage
    fi
    exit 79
fi

###################
#### FUNCTIONS ####
###################
function get_all_active_sids_on_server()
{
    ORATAB_ARRAY=( $(cat /etc/oratab | grep -v -E "^#" | grep -v -E "^$" | grep -v -E "^\*" | cut -d ':' -f1 | sort) );
    SIDS_TO_PROC=()

    for CUR_DB in ${ORATAB_ARRAY[*]};
    do
        IS_RUNNING=$(ps -ef | grep ora_pmon | grep -v grep | awk '{print $8}' | awk '{gsub(/ora\_pmon\_/, ""); print}' | grep -E "^${CUR_DB}$" | awk '{gsub(/'"$CUR_DB"'/, "running"); print}')
        if [ "${IS_RUNNING}" = "running" ]; then SIDS_TO_PROC+=("${CUR_DB}"); fi
    done;

    echo "${SIDS_TO_PROC[*]}"
}

function execute_sql_script_by_sid()
{
    CURRENT_SID="${1}"

    echo "---- Starting execution of ${SQL_FILE_NAME} on database ${CURRENT_SID} at $(date +'%Y-%m-%d %H:%M:%S') ----"
    echo ""

    su - oracle -c "
    function chdb_auto {
        INPUT_VALUE=\$1
        INPUT_DB_VAL=\$(echo \"\${INPUT_VALUE}\" | awk '{gsub(/ /, \"\"); print}')

        ORATAB_ARRAY=( \$(cat /etc/oratab | grep -v -E \"^#\" | grep -v -E \"^$\" | grep -v -E \"^\\*\" | cut -d ':' -f1 | sort) );

        MATCH_FOUND=\"FALSE\";

        for CUR_SID_EVAL in \${ORATAB_ARRAY[*]}
        do
            if [ \"\${CUR_SID_EVAL}\" = \"\${INPUT_DB_VAL}\" ]
            then
                MATCH_FOUND=\"TRUE\"
                CUR_SID=\"\${CUR_SID_EVAL}\"
                break
            fi
        done

        if [ \"\${MATCH_FOUND}\" = \"FALSE\" ]; then echo \"INVALID SID - \${INPUT_DB_VAL} PROVIDED.\"; exit 80; fi

        ORAENV_ASK=NO
        ORACLE_SID=\"\${CUR_SID}\"
        if [ -x /usr/local/bin/oraenv ]
        then
            ORAENV_PATH=\"/usr/local\"
        else
            ORAENV_PATH=\$(cat /etc/oratab | grep -v -E \"^#\" | grep -v -E \"^$\" | grep -v -E \"^\*\" | grep \${ORACLE_SID}: | cut -d ':' -f2)
        fi

        set +u
        . \${ORAENV_PATH}/bin/oraenv > /dev/null
    }

    chdb_auto ${CURRENT_SID}

    wait

    echo exit | sqlplus -S -L / ${SYSDBA_OPTION} @${SQL_TO_EXECUTE}
    "
    STATUS_CODE=$?

    echo ""
    echo "---- Finished execution of ${SQL_FILE_NAME} on database ${CURRENT_SID} at $(date +'%Y-%m-%d %H:%M:%S') ----"
    echo ""
    echo ""

    return ${STATUS_CODE}
}

#########################
#### MAIN PROCESSING ####
#########################
ERRORS_FOUND="FALSE"

if [ "${ALL_ARG_PASSED}" = "TRUE" ]
then
    ALL_ACTIVE_SIDS=( $(get_all_active_sids_on_server) )

    for CUR_ACTIVE_SID in ${ALL_ACTIVE_SIDS[*]}
    do
        execute_sql_script_by_sid "${CUR_ACTIVE_SID}"
        RETURN_CODE=$?
        if [ ${RETURN_CODE} -ne 0 ]
        then
            echo "EXIT CODE ${RETURN_CODE} ENCOUNTERD"
            ERRORS_FOUND="TRUE"
        fi
    done

else
    execute_sql_script_by_sid "${SID_TO_EVAL}"
    RETURN_CODE=$?
    if [ ${RETURN_CODE} -ne 0 ]
    then
        echo "EXIT CODE ${RETURN_CODE} ENCOUNTERD"
        ERRORS_FOUND="TRUE"
    fi
fi

#########################
#### POST-PROCESSING ####
#########################
rm -f ${SQL_TO_EXECUTE} > /dev/null

if [ "${ERRORS_FOUND}" = "TRUE" ]
then
    exit 100
fi

