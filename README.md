# icinga-playground
Vagrant playground for icinga tests

## usage
install needed vagrant plugins

`vagrant plugin install hosts vagrant-hosts vagrant-share vagrant-vbguest`

unpack files
adjust `viagrant-share/web/tests/all_tests.sh` and `viagrant-share/web/tests/testXX` as needed 

run the vagrant box
`vagrant up`

enter the box and run tests
`vagrant ssh porcino`
`sudo /viagrant-share/web/tests/all_tests.sh`

exit the box and fetch data from `viagrant-share/web/tests`
