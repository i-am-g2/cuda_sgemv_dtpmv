
echo "----------------------------------------"
echo "Generating Test Cases"
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	# echo -n -e "Dimension : $i $i\t\t\t" &&	./a.out < TestCases/case_$i.txt
	python3 Test_Generator.py $i > case_$i.txt
done
