
gdiff3 () {
    # $1 = File
    # [$2] = remote branch: if empty use 'origin/master' else e.g. HEAD~3 or /maint/release_1_2
    #

    # default configuration 
    LEMONTREE_EXE='/c/Program\ Files/LieberLieber/LemonTree/LemonTree.Starter.exe' # change path
    LEMONTREE_EXT="eapx eap" 
    KDIFF_EXE='~/programm/kdiff/kdiff3.exe' # change here

    # eval input
    LOCAL_EAP_FILE=$1

    if [ ! -f "${LOCAL_EAP_FILE}" ] ; then
        echo "No file named \"${LOCAL_EAP_FILE}\""
        exit 1
    fi

    # extract extension from file
    LOCAL_EAP_EXTENSION="${LOCAL_EAP_FILE##*.}"
    # convert to lower case 
    LOCAL_EAP_EXTENSION="${LOCAL_EAP_EXTENSION,,}"

    # eval branches
    if [ "$2" = "" ]; then
    REMOTE_BRANCH="origin/master"
    else
    REMOTE_BRANCH=$2
    fi

    LOCAL_BRANCH=$(git branch --show-current)

    # set output for BASE/REMOTE/LOCAL
    LOCAL_EAP_PATH=$(pwd  ${LOCAL_EAP_FILE})
    LOCAL_RANDOM_ID=$RANDOM

    REMOTE_MODEL=${LOCAL_EAP_PATH}/REMOTE_${LOCAL_RANDOM_ID}.${LOCAL_EAP_EXTENSION}
    LOCAL_MODEL=${LOCAL_EAP_PATH}/LOCAL_${LOCAL_RANDOM_ID}.${LOCAL_EAP_EXTENSION}
    BASE_MODEL=${LOCAL_EAP_PATH}/BASE_${LOCAL_RANDOM_ID}.${LOCAL_EAP_EXTENSION}

    CHECK_LFS_FILE=$(git lfs ls-files | grep ${LOCAL_EAP_FILE})

    if [ ! -z "${CHECK_LFS_FILE}" ]; then
        echo create copies of eap file \(LFS\)

        # create copy of files to compare
        echo create copy of local file \(branch: ${LOCAL_BRANCH}\)
        git show ${LOCAL_BRANCH}:${LOCAL_EAP_FILE} | git lfs smudge > ${LOCAL_MODEL}

        echo create copy of remote file \(branch: ${REMOTE_BRANCH}\)
        git show ${REMOTE_BRANCH}:${LOCAL_EAP_FILE} | git lfs smudge > ${REMOTE_MODEL}

        echo create copy of base
        git show `git merge-base ${LOCAL_BRANCH} ${REMOTE_BRANCH}`:${LOCAL_EAP_FILE} | git lfs smudge > ${BASE_MODEL}
    else
        echo create copies of eap file \(not LFS\)
        
        # create copy of files to compare
        echo create copy of local file \(branch: ${LOCAL_BRANCH}\)
        git show ${LOCAL_BRANCH}:${LOCAL_EAP_FILE} > ${LOCAL_MODEL}

        echo create copy of remote file \(branch: ${REMOTE_BRANCH}\) 
        git show ${REMOTE_BRANCH}:${LOCAL_EAP_FILE} > ${REMOTE_MODEL}

        echo create copy of base
        git show `git merge-base ${LOCAL_BRANCH} ${REMOTE_BRANCH}`:${LOCAL_EAP_FILE} > ${BASE_MODEL}
    fi

    # call lemontree starter with option diff
    if [[ "${LEMONTREE_EXT}" =~ ${LOCAL_EAP_EXTENSION} ]]; then
        echo ${LEMONTREE_EXE} diff --base ${BASE_MODEL} --theirs ${REMOTE_MODEL} --mine ${LOCAL_MODEL}
        eval ${LEMONTREE_EXE} diff --base ${BASE_MODEL} --theirs ${REMOTE_MODEL} --mine ${LOCAL_MODEL}
    else
        echo ${KDIFF_EXE} ${BASE_MODEL} ${REMOTE_MODEL} ${LOCAL_MODEL}
        eval ${KDIFF_EXE} ${BASE_MODEL} ${REMOTE_MODEL} ${LOCAL_MODEL}
    fi

    # remove files if not needed
    echo type "y" if created files should be deleted
    read input
    if [ "${input}" = "y" ]; then
        rm ${LOCAL_MODEL}
        rm ${REMOTE_MODEL}
        rm ${BASE_MODEL}
    fi

}
