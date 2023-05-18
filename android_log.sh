#!/bin/bash

# Map of error codes and error messages
declare -A ERROR_MESSAGES=(
  [1]="adb is not installed. Please install the Android SDK."
  [2]="No Android devices found. Please connect a device."
  [3]="Invalid option provided. Usage: start_android_log.sh [-f <filename>]"
  [4]="Logcat buffer overflow. Please reduce logging level or increase buffer size."
  [5]="Failed to create log directory."
  [6]="Failed to create log file."
  [7]="Failed to read logcat output."
  [8]="Invalid device selection"
  [9]="No devices connected"
  [10]=" "
)

# Function to remove whitespace from a string
remove_whitespace() {
    input_string="$1"
    cleaned_string=$(echo "$input_string" | sed 's/ /-/g')
    echo "$cleaned_string"
}

# Check if adb is installed
check_adb_installed() {
  if ! command -v adb &> /dev/null
  then
      echo ${ERROR_MESSAGES[1]}
      return 1
  fi
}

# Get connected devices
get_connected_devices() {
  adb_devices_output=$(adb devices)
  connected_devices=$(echo "$adb_devices_output" | grep "device$" | awk '{print $1}')
  if [ -z "$connected_devices" ]; then
      echo ${ERROR_MESSAGES[2]}
      return 2
  fi
}

# Prompt user for device selection
select_device() {
  num_devices=$(echo "$connected_devices" | wc -l)
  if [ "$num_devices" -gt 1 ]; then
      echo "Multiple devices connected. Please select a device:"

      index=1
      while IFS= read -r device; do
          echo "$index) $device"
          ((index++))
      done <<< "$connected_devices"

      read -rp "Enter the device number: " device_index

      if [[ "$device_index" =~ ^[0-9]+$ ]] && [ "$device_index" -ge 1 ] && [ "$device_index" -le "$num_devices" ]; then
          selected_device=$(echo "$connected_devices" | sed -n "${device_index}p")
          echo "Selected device: $selected_device"
      else
          echo ${ERROR_MESSAGES[8]}
          return 8
      fi
  else
      selected_device=$connected_devices
      echo "Connected device: $selected_device"
  fi
}

# Process command line arguments
process_arguments() {
  filename=$1
  manufacturer_name_pre=$(adb -s $selected_device shell getprop ro.product.manufacturer)
  manufacturer_name=$(remove_whitespace "$manufacturer_name_pre")
  model_name_raw=$(adb -s $selected_device shell getprop ro.product.model)
  model_number=$(remove_whitespace "$model_name_raw")
  separator="_"
  foldername="$manufacturer_name$separator$model_number"
  while getopts ":f:" opt; do
    case $opt in
      f)
        filename=$OPTARG
        echo "file is picked and will be updated"
        ;;
      \?)
        echo ${ERROR_MESSAGES[3]}
        return 3
        ;;
      :)
        echo ${ERROR_MESSAGES[3]}
        return 3
        ;;
    esac
  done
  echo "Filename: "$filename
  if [ -z "$filename" ]; then
    filename="logcat"
  fi
   echo "Filename post: "$filename
  divider=""
  date=$(date +%Y%m%d%H%M%S)
  extension=".log"
  filename=$filename$divider$date$extension
  finalFolderName="/media/kneeraj/HDD/logs/"
  full_file_path=$finalFolderName$foldername/$filename

  echo $full_file_path
}

# Create log file
create_log_file() {
  if ! mkdir -p "$(dirname "$full_file_path")"; then
    echo ${ERROR_MESSAGES[5]}
    return 5
  fi

  if ! touch "$full_file_path"; then
    echo ${ERROR_MESSAGES[6]}
    return 6
  fi
}

take_logcat() {
  echo "Command used to take logs: adb -s $selected_device logcat"
  adb -s $selected_device logcat > $full_file_path | glogg $full_file_path > /dev/null 2>&1
}

main() {
  check_adb_installed || return 1
  get_connected_devices || return 2
  select_device || return 8
  process_arguments "$1" || return 3
  create_log_file || return 6
  take_logcat
}

main $1