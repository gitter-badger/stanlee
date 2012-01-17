#!/bin/bash

ROOTFLDR="$( pwd )"
GITHUBWIKI="${ROOTFLDR}/documentation/githubwiki"
GOOGLBWIKI="${ROOTFLDR}/documentation/googlewiki"
VERSION="${ROOTFLDR}/VERSION"
CHANGELOG="${ROOTFLDR}/ChangeLog"
CHANGES="$( tempfile )"
NEWCHANGES="$( tempfile )"
DATE=$( date +%D )
SNAPSHOT=$( date +%Y%m%d%H%M%S )

if [ "$( git branch 2> /dev/null | sed -e '/^[^*]/d;s/\* //' )" != "development" ]; then
	echo "You are not on \"development\" branch."
	echo "Make sure you made your changes on the appropiate branch."
	exit 1
fi

git add .
git commit -a

if [ $? == 1 ]; then
	exit 1
fi

git log > ${CHANGES}

OLDVERSION=$( cat ${VERSION} | grep "VERSION" | sed 's/VERSION = //g' )
OLDCOMMIT=$( cat ${VERSION} | grep "COMMIT" | sed 's/COMMIT = //g' )
OLDCOMMITLINE=$( cat ${CHANGES}  | grep -n "${OLDCOMMIT}" | awk -F: '{print $1}' )

read -p "Enter new version (last version was ${OLDVERSION}): "
NEWVERSION="${REPLY}"

echo "DEVELOPMENT RELEASE v${NEWVERSION}+${SNAPSHOT} (${DATE})" > ${NEWCHANGES}
cat ${CHANGES} | sed -n 1,${OLDCOMMITLINE}p | sed 's/commit.*//g;s/Author:.*//g;s/Date:.*//g;s/Merge.*//g;/^$/d;' >> ${NEWCHANGES}
sed -i 's/New development snapshot.*//g' ${NEWCHANGES}
echo "" >> ${NEWCHANGES}
cat ${CHANGELOG} >> ${NEWCHANGES}
mv ${NEWCHANGES} ${CHANGELOG}
rm ${CHANGES}

LASTCOMMIT=$( git rev-parse HEAD )

echo "VERSION = ${NEWVERSION}+${SNAPSHOT}" > ${VERSION}
echo "COMMIT = ${LASTCOMMIT}" >> ${VERSION}

cd ${GOOGLEWIKI}
git add .
git commit -a -m "Updating documentation"
git push --tags https://code.google.com/p/aguilas.wiki/ development

cd ${GITHUBWIKI}
git add .
git commit -a -m "Updating documentation"
git push --tags git@github.com:HuntingBears/aguilas.wiki.git development

git add .
git commit -a -m "New development snapshot ${NEWVERSION}+${SNAPSHOT}"
git tag ${NEWVERSION}+${SNAPSHOT} -m "New development snapshot ${NEWVERSION}+${SNAPSHOT}"

git push --tags git@github.com:HuntingBears/aguilas.git development
git push --tags git@gitorious.org:huntingbears/aguilas.git development
git push --tags https://code.google.com/p/aguilas/ development
