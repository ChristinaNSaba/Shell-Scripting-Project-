echo "Enter the name of the file you want to read from" #asking the user to enter the name of file to read data from
read filename
[ ! -e $filename ]
check=$(echo $?) #making sure that the name entered is correct otherwise a message pops and says that the entered value is incorrect
if [ $check -eq 0 ]
then 
echo "The file $filename  does not exist"
exit 1
fi
cp $filename test.txt #copying the file to another temporary file
while true #showing the menu of choices for the user to choose from
do 
echo "                      MAIN MENU                       "
echo " =========================================================="
echo "[1] Show student records for all semesters "
echo "[2] Show student records for a specific semester"
echo "[3] Show overall average"
echo "[4] Show average for every semester"
echo "[5] Show the total number of passed hours"
echo "[6] Show the precentage of total passed hours in relation to total F and FA hours"
echo "[7] Show total number of hours taken in every semester"
echo "[8] Show the total number of courses taken"
echo "[9] Show the total number of labs taken"
echo "[10] Insert the new semester record"
echo "[11] Change in course grade"
echo "[12] Exit program"
echo "==========================================================="
echo "Enter the number of operation you want to perfom"
read value
case "$value"
in
1) #the first choice is to display the records taken through the years in the text file
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' #grep command to get all the lines in the file of courses in each line after using the pipe and cutting the data
;;
##############################################################
2) #the second choice is to display the list of courses of the semester entered by the user
echo "Enter the semester to show the records"
read line
grep "$line" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' #grep the line which has the value entered by the user and cutting it to display the record
;;
###############################################################
3) #the third choice is to display the overall average of the whole semesters 
avg=0
avgsum=0
hoursummation=0
mult=0
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sed 's/FA/50/' | sed 's/F/55/' | sort -r | uniq -w 9 | cut -d' ' -f3 > g.txt #separating the grades
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sed 's/FA/50/' | sed 's/F/55/' | sort -r | uniq -w 9 | cut -c7 > hour.txt #separating the hours using cut -c7
paste g.txt hour.txt > avg.txt # pasting the values to the same file to read from and calculate the average by multiplying each grade by its hour then computing the summation and divide them by the sum of the hours 
files="avg.txt"
while read -r VAR1 VAR2; do
  g=$VAR1
  h=$VAR2
  (( hoursummation += h ))
  mult=$(( g * h ))
  (( avgsum += mult ))
done <$files
echo "The overall average is: $(bc -l <<<"${avgsum}/${hoursummation}")"
;;
################################################################
4) #the fouth choice is to display each semester's average separately 
sed '1d' file.txt > test.txt
r="test.txt"
echo "Each semester has an average of:"
while IFS= read -r line; do
semhours=0
mul=0
average=0
echo $line | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | sed 's/FA/50/' | sed 's/F/55/' | cut -d' ' -f3 > semgrades.txt #putting the grades in a file
echo $line | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | cut -c7 > semhours.txt # putting the hours in a file
paste semgrades.txt semhours.txt > semavg.txt #pasting the values in the same file to compute the average 
k="semavg.txt"
while read -r VAR1 VAR2; do
a=`echo $VAR1`
b=`echo $VAR2`
(( semhours += b ))
 mul=$(( a * b ))
(( average += mul ))
done <$k
echo $(bc -l <<<"${avgsum}/${hoursummation}")
done <$r
;;
#################################################################
5) #the fifth choice is to compute the total passed hours taken and without any repitition in courses
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | grep -v "F" | grep -v "FA" | sort -r | uniq -w 9 | cut -c7 > hours.txt #taking the hours of every course that is unique and saving them in a file
file1="hours.txt"
psum=0
phour=0
while read -r line; do #while loop to compute the summation of the hours passed
phour=$line
(( psum += phour ))
done <$file1
echo "The total passed hours are: $psum"
;;
#################################################################
6) #the sixth choice is to find the precentage of F and FA divided by the summation of passed hours 
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sort -r | uniq -w 9 | cut -d' ' -f3 > totalgrades.txt
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | grep -v "F" | grep -v "FA" | sort -r | uniq -w 9 | cut -c7 > FA.txt
numFA=$(grep 'FA\|F' totalgrades.txt | wc -l) #couting the number of lines in the file FA.txt which has the hours as each line is represented by an hour
file2="FA.txt"
passsum=0
h=0
while read -r line; do
h=$line
(( psum += h ))
done <$file2
percentage=$(bc -l <<<"${numFA}/${psum}") #dividing the number of F and FA found by the total number of hours passed
echo "the percentage of F and FA is $percentage"
;;
#################################################################
7) #the seventh choice is to find the total taken hours of each semester seperately 

sed '1d' file.txt > test.txt
f="test.txt"
echo "Each semester has a total taken hours of:"
while read -r line; do
sum=0
semhour=0
echo $line | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | cut -c7 > semhours.txt #cutting each line which represents a semester and saving the hours in a separate file 
file3="semhours.txt"
while read -r line; do
semhour=$line
(( sum += semhour ))
done <$file3
echo $sum
done <$f
;;
#################################################################
8) #the eighth choice is to print the total number of hours taken of the unique courses
echo "Total number of courses taken is: $(grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sort -r | uniq -w 9 | wc -l)"
;;
#################################################################
9) #the ninth choice is to find the total hours of lab courses in which the hour should be equal to 1 
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sort -r | uniq -w 9 | cut -c7 > lab.txt
file4="lab.txt"
labcount=0
while read -r line; do
labhour=$line
if [ $labhour -eq 1 ] #making sure if the hour is 1 then the count is incremented by one
then
(( labcount += 1 ))
fi
done <$file4
echo "The number of labs taken is: $labcount"
;;
################################################################
10) #the tenth choice is to ask the user to enter a whole semester record with restriction on the inputs and if it was correct then add to the file of records
echo "Enter the record you want to add:"
read record
echo $record | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | cut -d' ' -f2 > recordcourses.txt
echo $record | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sed 's/FA/50/' | sed 's/F/55/' | cut -d' ' -f3 > recordgrades.txt
echo $record | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | grep -v "I" | sed 's/FA/50/' | sed 's/F/55/' | cut -c7 > recordhours.txt
recordgrades="recordgrades.txt"
recordcourses="recordcourses.txt"
recordhours="recordhours.txt"
#reading the courses and making sure it begins with ENCS or ENEE
while read -r line; do
if [ `echo $line | grep -q "ENCS"` -o `echo $line | grep -q "ENEE"` ]
then
:
fi
if [ $? -ne 0 ]
then 
echo "This record cannot be added"
break 
fi
done <$recordgrades
#reading the grade and making sure each grade is between 60 and 99 or F or FA
while read -r line; do
if [ $line -gt 60 -a $line -lt 99 -o $line = "FA" -o $line = "F" -o $line = "I" ]
then 
:
else 
echo "This record cannot be added"
break 
fi
done <$recordgrades
#reading the hours and making sure the summation is not less than 12
recordsummation=0
while read -r line; do
(( recordsummation += $line ))
done <$recordhours
if [ $recordsummation -lt 12 ]
then 
echo "This record cannot be added"
break 
fi
if [ $? -ne 0 ]
then
echo "This record cannot be added"
else
echo $semester >> file.txt
fi
;;
################################################################
11)#the eleventh choice is to change a chosen grade from the user and making sure the user wants to change if the course is found
echo "Enter the course code you are trying to change:"
read code
echo "Enter the new grade you are trying to provide:"
read newgrade
grep "EN" file.txt | tr -s ' ' ' ' | cut -d';' -f2 | tr ',' '\n' | sed 's/FA/50/' | sed 's/F/55/' > newcourses.txt
oldcourse=$(grep $code newcourses.txt)
echo "Old course is $oldcourse"
echo "Do you want to change the grade? (yes or no)"
read answer
if [ $answer = 'yes' ]
then
sed -i "s/$oldcourse/ $code $newgrade/g" file.txt #using the sed command to change the old value with a new oneS
echo "This grade is changed successfully"
else
echo "The grade is not changed"
fi
;;
################################################################
12) #the twelveth choice is to exit the program 
echo "Exitting the program"
exit 0
;;
################################################################
esac
done