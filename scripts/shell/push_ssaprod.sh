cd  ~/code/SSA_PROD_puppet
git checkout master
git pull
git checkout ssaprod
git pull
git merge master --no-edit
git tag `date +%C%y%m%d-ssaprod-%H%M`
git push
git push --tags