SHORT_SHA1=`echo -n $CIRCLE_SHA1 | head -c 7`

if [ `echo "$CIRCLE_REPOSITORY_URL" | grep "^git@github.com"` ]; then
    COMMIT_LINK=\[$SHORT_SHA1\]\(https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commit/$CIRCLE_SHA1\)
elif [ `echo "$CIRCLE_REPOSITORY_URL" | grep "^git@bitbucket.org"` ]; then
    COMMIT_LINK=\[$SHORT_SHA1\]\(https://bitbucket.org/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commit/$CIRCLE_SHA1\)
else
    >&2 echo unknown version control system: $CIRCLE_REPOSITORY_URL
    fail
fi

if [[ $SHOW_MSG == "true" ]]; then
    COMMIT_MSG=`git log --format=%B -1 $CIRCLE_SHA1`
else
    COMMIT_MSG="n/a"
fi

if [[ $SHOW_AUTHOR == "true" ]]; then
    COMMIT_AUTHOR=`git log --format="%an <%ae>" -1 $CIRCLE_SHA1`
else
    COMMIT_AUTHOR="n/a"
fi

MS_TEAMS_MSG_TEMPLATE=$(cat <<END_HEREDOC
{
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "themeColor": "__theme_color__",
    "summary": "CircleCI Build Notification",
    "sections": [
        {
            "activityTitle": "__build_status__: $CIRCLE_PROJECT_REPONAME job [${CIRCLE_JOB} #${CIRCLE_BUILD_NUM}]($CIRCLE_BUILD_URL)",
            "facts": [
                {
                    "name": "Git ref",
                    "value": "$CIRCLE_BRANCH $CIRCLE_TAG"
                },
                {
                    "name": "Commit",
                    "value": "$COMMIT_LINK"
                },
                {
                    "name": "Message",
                    "value": "$COMMIT_MSG"
                },
                {
                    "name": "Author",
                    "value": "$COMMIT_AUTHOR"
                }
            ],
            "markdown": true
        }
    ]
}
END_HEREDOC
)

echo "$MS_TEAMS_MSG_TEMPLATE" > /tmp/ms_teams_message
echo 'export MS_TEAMS_MSG_TEMPLATE="'$MS_TEAMS_MSG_TEMPLATE'"' >> "$BASH_ENV"
