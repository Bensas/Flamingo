make all
echo "Fibonacci test:"
./flamingompiler Examples/fibonacci.flamingo
echo "======================="
echo "Primality test for 32353: "
./flamingompiler Examples/primality_test.flamingo
echo "======================="
echo "Primality test for 11111: "
./flamingompiler Examples/primality_test_11111.flamingo
echo "======================="
echo "Deutsch const 0:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_Constant0.flamingo
echo "======================="
echo "Deutsch const 1:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_Constant1.flamingo
echo "======================="
echo "Deutsch ID:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_ID.flamingo 
echo "======================="
echo "Deutsch NOT:"
./flamingompiler Examples/DeutschAlgorithm/Deutsch_NOT.flamingo 
echo "======================="
echo "Teleportation of |0>"
./flamingompiler Examples/Teleportation/Teleportation_0.flamingo
echo "======================="
echo "Teleportation of |1>"
./flamingompiler Examples/Teleportation/Teleportation_1.flamingo
echo "======================="
echo "Teleportation of |+>"
./flamingompiler Examples/Teleportation/Teleportation_+.flamingo
echo "======================="
echo "Teleportation of |->"
./flamingompiler Examples/Teleportation/Teleportation_-.flamingo
echo "======================="
