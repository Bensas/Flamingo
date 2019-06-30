make all
echo "Fibonacci test:"
./flamingompiler Examples/fibonacci.flamingo
echo "Deutsch const 0:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_Constant0.flamingo
echo "Deutsch const 1:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_Constant1.flamingo
echo "Deutsch ID:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_ID.flamingo 
echo "Deutsch NOT:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_NOT.flamingo 
echo "Teleportation of |0>"
./flamingompiler Examples/Teleportation/Teleportation_0.flamingo
echo "Teleportation of |1>"
./flamingompiler Examples/Teleportation/Teleportation_1.flamingo
echo "Teleportation of |+>"
./flamingompiler Examples/Teleportation/Teleportation_+.flamingo
echo "Teleportation of |->"
./flamingompiler Examples/Teleportation/Teleportation_-.flamingo
