#!/bin/bash

# === File Paths ===
STUDENTS_FILE="students.txt"
TEACHERS_FILE="teachers.txt"
COURSES_FILE="courses.txt"
ATTENDANCE_FILE_PREFIX="attendance_"
GRADES_FILE="grades.txt"
TIMETABLES_FILE="timetables.txt"
USERS_FILE="users.txt"

# === Utility Functions ===
pause() {
  read -p "Press Enter to continue..."
}

header() {
  clear
  echo "========================="
  echo "SmartEduCLI - School System"
  echo "========================="
}

login() {
  header
  echo "Login Required"
  read -p "Username: " username
  read -s -p "Password: " password
  echo
  user_info=$(grep "^$username," "$USERS_FILE")

  if [[ -z "$user_info" ]]; then
    echo "Invalid username."
    pause
    return 1
  fi

  saved_pass=$(echo "$user_info" | cut -d',' -f2)
  role=$(echo "$user_info" | cut -d',' -f3)
  if [[ "$password" == "$saved_pass" ]]; then
    echo "Login successful as $role."
    pause
    return 0
  else
    echo "Invalid password."
    pause
    return 1
  fi
}

add_student() {
  read -p "Student ID: " sid
  grep -q "^$sid," "$STUDENTS_FILE" && { echo "Student ID already exists."; return; }
  read -p "Name: " name
  read -p "Class: " class
  read -p "Section: " section
  read -p "Phone: " phone
  echo "$sid,$name,$class,$section,$phone" >> "$STUDENTS_FILE"
  echo "Student added."
}

view_students() {
  column -t -s',' "$STUDENTS_FILE"
}

edit_student() {
  read -p "Enter Student ID to edit: " sid
  record=$(grep "^$sid," "$STUDENTS_FILE")
  [[ -z "$record" ]] && { echo "Student not found."; return; }
  read -p "New Name: " name
  read -p "New Class: " class
  read -p "New Section: " section
  read -p "New Phone: " phone
  sed -i "/^$sid,/c\$sid,$name,$class,$section,$phone" "$STUDENTS_FILE"
  echo "Student updated."
}

delete_student() {
  read -p "Enter Student ID to delete: " sid
  sed -i "/^$sid,/d" "$STUDENTS_FILE"
  echo "Student deleted."
}

manage_students() {
  while true; do
    header
    echo "1. Add Student"
    echo "2. View Students"
    echo "3. Edit Student"
    echo "4. Delete Student"
    echo "5. Back"
    read -p "Choose an option: " opt
    case $opt in
      1) add_student;;
      2) view_students; pause;;
      3) edit_student; pause;;
      4) delete_student; pause;;
      5) break;;
      *) echo "Invalid option."; pause;;
    esac
  done
}

add_teacher() {
  read -p "Teacher ID: " tid
  grep -q "^$tid," "$TEACHERS_FILE" && { echo "Teacher ID exists."; return; }
  read -p "Name: " name
  read -p "Subject: " subject
  read -p "Phone: " phone
  echo "$tid,$name,$subject,$phone" >> "$TEACHERS_FILE"
  echo "Teacher added."
}

manage_teachers() {
  header
  add_teacher
  pause
}

add_course() {
  read -p "Course ID: " cid
  grep -q "^$cid," "$COURSES_FILE" && { echo "Course exists."; return; }
  read -p "Title: " title
  read -p "Class Level: " class
  read -p "Subject: " subject
  read -p "Teacher ID: " tid
  echo "$cid,$title,$class,$subject,$tid" >> "$COURSES_FILE"
  echo "Course added."
}

manage_courses() {
  header
  add_course
  pause
}

mark_attendance() {
  date_today=$(date +%Y%m%d)
  file="$ATTENDANCE_FILE_PREFIX$date_today.txt"
  echo "Marking attendance for $date_today"
  while read -r line; do
    sid=$(echo "$line" | cut -d',' -f1)
    name=$(echo "$line" | cut -d',' -f2)
    read -p "$sid - $name (P/A): " status
    echo "$sid,$status" >> "$file"
  done < "$STUDENTS_FILE"
  echo "Attendance saved to $file"
}

add_grade() {
  read -p "Student ID: " sid
  read -p "Course ID: " cid
  read -p "Marks: " marks
  grade="F"
  if (( marks >= 90 )); then grade="A"; elif (( marks >= 75 )); then grade="B"; elif (( marks >= 60 )); then grade="C"; elif (( marks >= 40 )); then grade="D"; fi
  echo "$sid,$cid,$marks,$grade" >> "$GRADES_FILE"
  echo "Grade recorded: $grade"
}

generate_report() {
  read -p "Student ID: " sid
  report="report_$sid.txt"
  echo "Report for Student ID: $sid" > "$report"
  echo "Attendance:" >> "$report"
  grep "^$sid," ${ATTENDANCE_FILE_PREFIX}*.txt >> "$report"
  echo "\nGrades:" >> "$report"
  grep "^$sid," "$GRADES_FILE" >> "$report"
  echo "Report saved to $report"
}

main_menu() {
  while true; do
    header
    echo "Logged in as: $role"
    echo "1. Manage Students"
    echo "2. Manage Teachers"
    echo "3. Manage Courses"
    echo "4. Mark Attendance"
    echo "5. Enter Grades"
    echo "6. Generate Report"
    echo "7. Logout"
    read -p "Select an option: " choice

    case $choice in
      1) manage_students;;
      2) [[ $role == "Admin" ]] && manage_teachers || echo "Access Denied"; pause;;
      3) [[ $role == "Admin" ]] && manage_courses || echo "Access Denied"; pause;;
      4) mark_attendance; pause;;
      5) add_grade; pause;;
      6) generate_report; pause;;
      7) break;;
      *) echo "Invalid choice."; pause;;
    esac
  done
}

# === Start Script ===
while true; do
  header
  echo "1. Login"
  echo "2. Exit"
  read -p "Choose an option: " opt
  case $opt in
    1)
      login && main_menu
      ;;
    2)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
  pause
  clear
  done

