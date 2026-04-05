#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="./data"
LOG_DIR="./logs"
BACKUP_DIR="./backup"

mkdir -p "$DATA_DIR" "$LOG_DIR" "$BACKUP_DIR"

STUD_DB="$DATA_DIR/students.txt"
CSV_FILE="$DATA_DIR/students.csv"
LOG_FILE="$LOG_DIR/activity.log"

touch "$STUD_DB" "$LOG_FILE"

ADMIN_USER="admin"
ADMIN_PASS="12345"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ======================
# UI
# ======================

header() {
  clear
  echo -e "${CYAN}"
  echo "========================================"
  echo "     SYSTEM ADMIN TOOLKIT v3.1"
  echo "========================================"
  echo -e "${NC}"
}

quote() {
  clear
  echo -e "${YELLOW}"
  echo "Automate everything you can. Human time is valuable."
  echo -e "${NC}"
  sleep 2
}

pause() {
  echo
  read -p "Press Enter to continue..."
}

log_action() {
  echo "$(date) - $1" >> "$LOG_FILE"
}

# ======================
# TABLE VIEW
# ======================

view_students_table() {
  header
  printf "%-5s | %-20s\n" "ID" "NAME"
  echo "-----------------------------------"
  nl -w2 -s'   | ' "$STUD_DB"
  pause
}

# ======================
# USER MONITOR
# ======================

user_monitor() {
  header
  echo -e "${GREEN}Active Users:${NC}"
  who
  echo
  w
  log_action "User monitoring"
  pause
}

# ======================
# DISK CLEANUP
# ======================

disk_cleanup() {
  header
  echo "Confirm cleanup? (y/n): "
  read c

  if [[ "$c" == "y" ]]; then
    echo
    echo "Cleaning temp files..."

    rm -rf /tmp/* 2>/dev/null || true

    echo "Cleanup completed successfully."
    log_action "Disk cleanup executed"
  else
    echo
    echo "Cleanup cancelled."
  fi

  pause
}
# ======================
# BACKUP
# ======================

backup_data() {
  header
  FILE="$BACKUP_DIR/data_$(date +%F_%H-%M).tar.gz"
  tar -czf "$FILE" data/
  echo "Backup Created: $FILE"
  log_action "Backup"
  pause
}

# ======================
# HEALTH
# ======================

system_health() {
  header
  uptime
  echo
  free -h
  echo
  df -h
  log_action "Health"
  pause
}

# ======================
# CSV EXPORT
# ======================

export_csv() {
  header
  awk '{print NR","$0}' "$STUD_DB" > "$CSV_FILE"
  echo "CSV Exported: $CSV_FILE"
  log_action "CSV Export"
  pause
}

# ======================
# ATTENDANCE
# ======================

attendance() {
  header
  echo "USER       LOGIN TIME"
  echo "----------------------------"

  if who | grep -q .; then
    who | awk '{print $1"     "$3" "$4}'
  else
    echo "No active users found"
  fi

  log_action "Attendance"
  pause
}

# ======================
# STUDENT MODULE
# ======================

student_module() {
  while true; do
    header
    echo "1) View (Table)"
    echo "2) Add"
    echo "3) Delete"
    echo "4) Export CSV"
    echo "5) Back"

    read -p "Choice: " c

    case "$c" in
      1) view_students_table ;;
      2)
        read -p "Enter name: " s
        echo "$s" >> "$STUD_DB"
        log_action "Added $s"
        ;;
      3)
        read -p "Keyword: " k
        grep -v "$k" "$STUD_DB" > temp && mv temp "$STUD_DB"
        log_action "Deleted $k"
        ;;
      4) export_csv ;;
      5) return ;;
      *) echo "Invalid"; pause ;;
    esac
  done
}
about_section() {
  header
  echo "========================================"
  echo "        SHELL SYSTEM ADMIN TOOLKIT"
  echo "========================================"
  echo
  echo "Course        : Operating Systems Lab"
  echo "Project Type  : Shell-Based Automation Toolkit"
  echo "Developer     : Asif Khandoker"
  echo "Version       : 3.1"
  echo
  echo "----------------------------------------"
  echo "FEATURES:"
  echo "----------------------------------------"
  echo "1. User Monitoring (who, w)"
  echo "2. Disk Cleanup Automation"
  echo "3. Backup System with Timestamp"
  echo "4. System Health Monitoring"
  echo "5. Student Management System"
  echo "6. CSV Export Functionality"
  echo "7. Attendance Tracking (Login Data)"
  echo "8. Activity Logging System"
  echo
  echo "----------------------------------------"
  echo "TECHNOLOGIES USED:"
  echo "----------------------------------------"
  echo "- Bash Shell Scripting"
  echo "- Linux Commands"
  echo "- File Handling"
  echo "- Process Monitoring"
  echo "- Automation Tools"
  echo
  echo "----------------------------------------"
  echo "PROJECT OBJECTIVE:"
  echo "----------------------------------------"
  echo "To automate system administration tasks"
  echo "and reduce manual effort using shell scripting."
  echo
  echo "----------------------------------------"
  echo "QUOTE:"
  echo "----------------------------------------"
  echo "Automate everything you can. Human time is valuable."
  echo
  pause
}

# ======================
# MAIN MENU
# ======================

main_menu() {
  while true; do
    header
    echo "1) Students"
    echo "2) Monitor"
    echo "3) Cleanup"
    echo "4) Backup"
    echo "5) Health"
    echo "6) Attendance"
    echo "7) About"
    echo "8) Exit"

    read -p "Choose: " ch

    case "$ch" in
      1) student_module ;;
      2) user_monitor ;;
      3) disk_cleanup ;;
      4) backup_data ;;
      5) system_health ;;
      6) attendance ;;
      7) about_section ;;
      8) exit ;;
      *) echo "Invalid"; pause ;;
    esac
  done
}

# ======================
# LOGIN
# ======================

login() {
  header
  read -p "Username: " u
  read -s -p "Password: " p
  echo

  if [[ "$u" == "$ADMIN_USER" && "$p" == "$ADMIN_PASS" ]]; then
    log_action "Login success"
    main_menu
  else
    echo "Wrong credentials"
    log_action "Login fail"
    pause
  fi
}

# ======================
# START
# ======================

quote

while true; do
  header
  echo "1) Login"
  echo "2) Exit"

  read -p "Choice: " ch

  case "$ch" in
    1) login ;;
    2) exit ;;
    *) echo "Invalid"; pause ;;
  esac
done
