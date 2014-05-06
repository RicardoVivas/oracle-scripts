cd  ~/code/PROD_puppet
git fetch origin
git checkout master
git pull
git checkout production
git pull
git merge master --no-edit
git tag `date +prod-%d%m%y-%H%M`
git push
git push --tags