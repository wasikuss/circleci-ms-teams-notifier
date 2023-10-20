set -x

MSG_PATH=/tmp/ms_teams_replaced_message

sed -e 's/__build_status__/'$STATUS'/' -e 's/__build_color__/'$COLOR'/' \
    -e 's/__build_img__/'$IMG'/' /tmp/ms_teams_message > $MSG_PATH
curl --fail -H "Content-Type: application/json" --data-binary @$MSG_PATH \
    $MS_TEAMS_WEBHOOK_URL
