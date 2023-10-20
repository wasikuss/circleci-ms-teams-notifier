SHORT_SHA1=`echo -n $CIRCLE_SHA1 | head -c 7`

if [ `echo "$CIRCLE_REPOSITORY_URL" | grep "^git@github.com"` ]; then
    COMMIT_LINK=\[$SHORT_SHA1\]\(https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commit/$CIRCLE_SHA1\)
elif [ `echo "$CIRCLE_REPOSITORY_URL" | grep "^git@bitbucket.org"` ]; then
    COMMIT_LINK=\[$SHORT_SHA1\]\(https://bitbucket.org/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commit/$CIRCLE_SHA1\)
else
    >&2 echo unknown version control system: $CIRCLE_REPOSITORY_URL
    fail
fi

if [[ $SHOW_MSG == "1" ]]; then
    COMMIT_MSG=`git log --format=%B -1 $CIRCLE_SHA1`
else
    COMMIT_MSG="n/a"
fi

if [[ $SHOW_AUTHOR == "1" ]]; then
    COMMIT_AUTHOR_NAME=`git log --format="%an" -1 $CIRCLE_SHA1`
    COMMIT_AUTHOR_MAIL=`git log --format="%ae" -1 $CIRCLE_SHA1`
else
    COMMIT_AUTHOR_NAME="n/a"
    COMMIT_AUTHOR_MAIL="n/a"
fi

MS_TEAMS_MSG_TEMPLATE=$(cat <<END_HEREDOC
{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "contentUrl": null,
            "content": {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "Container",
                        "bleed": true,
                        "backgroundImage": {
                            "url": "__build_img__"
                        }
                    },
                    {
                        "type": "Container",
                        "items": [
                            {
                                "type": "ColumnSet",
                                "columns": [
                                    {
                                        "type": "Column",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "STATUS:",
                                                "weight": "Bolder"
                                            }
                                        ],
                                        "width": "auto",
                                        "horizontalAlignment": "Left"
                                    },
                                    {
                                        "type": "Column",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "__build_status__",
                                                "weight": "Bolder",
                                                "color": "__build_color__"
                                            }
                                        ],
                                        "width": "auto",
                                        "spacing": "Small"
                                    }
                                ]
                            },
                            {
                                "type": "TextBlock",
                                "text": "$CIRCLE_PROJECT_REPONAME job [${CIRCLE_JOB} #${CIRCLE_BUILD_NUM}]($CIRCLE_BUILD_URL)",
                                "weight": "Bolder"
                            },
                            {
                                "type": "FactSet",
                                "facts": [
                                    {
                                        "title": "Git ref",
                                        "value": "$CIRCLE_BRANCH $CIRCLE_TAG"
                                    },
                                    {
                                        "title": "Commit",
                                        "value": "$COMMIT_LINK"
                                    },
                                    {
                                        "title": "Message",
                                        "value": "$COMMIT_MSG"
                                    },
                                    {
                                        "title": "Author",
                                        "value": "<at>$COMMIT_AUTHOR_NAME</at>"
                                    }
                                ]
                            }
                        ],
                        "bleed": true
                    }
                ],
                "msteams": {
                    "entities": [
                        {
                            "type": "mention",
                            "text": "<at>$COMMIT_AUTHOR_NAME</at>",
                            "mentioned": {
                                "id": "$COMMIT_AUTHOR_EMAIL",
                                "name": "$COMMIT_AUTHOR_NAME"
                            }
                        }
                    ]
                },
                "\$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "version": "1.5"
            }
        }
    ]
}
END_HEREDOC
)

echo "$MS_TEAMS_MSG_TEMPLATE" > /tmp/ms_teams_message
