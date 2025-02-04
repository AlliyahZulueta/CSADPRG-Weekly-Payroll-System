# Default configuration settings
daily_rate <- 500
max_regular_hours_per_day <- 8
work_days_per_week <- 5
rest_days_per_week <- 2
normal_out_time <- 1700
overtime_hours <- 0

# Calculate the hourly rate
calculate_hourly_rate <- function(daily_rate, max_regular_hours_per_day) {
  hourly_rate <- daily_rate / max_regular_hours_per_day
  return(hourly_rate)
}

# Check if night shift
is_night_shift <- function(out_time) {
  return(out_time >= 2200 && out_time < 600)
}

# Calculate overtime
calculate_overtime_salary <- function(total_hours_worked, hourly_rate, is_night_shift_day, day_type) {
  # Overtime rates
  normal_day_rate <- 1.25
  night_shift_rate <- 1.375

  if (total_hours_worked <= max_regular_hours_per_day) {
    return(0)
  } else {
    regular_hours <- max_regular_hours_per_day
    overtime_hours <- total_hours_worked - max_regular_hours_per_day

    if (is_night_shift_day) {
      night_shift_overtime_rate <- switch(day_type,
        "normal" = night_shift_rate,
        "rest" = night_shift_rate * 1.169,  # Rest Day Night Shift Rate
        "special" = night_shift_rate * 1.169,  # Special Non-Working Day Night Shift Rate
        "special_rest" = night_shift_rate * 1.195,  # Special Non-Working Day and Rest Day Night Shift Rate
        "holiday" = night_shift_rate * 2.86,  # Regular Holiday Night Shift Rate
        "holiday_rest" = night_shift_rate * 3.718  # Regular Holiday and Rest Day Night Shift Rate
      )
      
      return(overtime_hours * night_shift_overtime_rate * hourly_rate)
    } else {
      normal_overtime_rate <- switch(day_type,
        "normal" = normal_day_rate,
        "rest" = normal_day_rate * 1.69,  # Rest Day Non-Night Shift Rate
        "special" = normal_day_rate * 1.69,  # Special Non-Working Day Non-Night Shift Rate
        "special_rest" = normal_day_rate * 1.95,  # Special Non-Working Day and Rest Day Non-Night Shift Rate
        "holiday" = normal_day_rate * 2.6,  # Regular Holiday Non-Night Shift Rate
        "holiday_rest" = normal_day_rate * 3.38  # Regular Holiday and Rest Day Non-Night Shift Rate
      )

      return(overtime_hours * normal_overtime_rate * hourly_rate)
    }
  }
}

# Calculate daily salary
calculate_daily_salary <- function(in_time, out_time, hourly_rate, day_type) {
  total_hours_worked <- (out_time - in_time) / 100

  if (total_hours_worked <= max_regular_hours_per_day) {
    day_salary <- hourly_rate * total_hours_worked
    overtime_hours <- 0
  } else {
    regular_hours <- max_regular_hours_per_day
    overtime_hours <- total_hours_worked - max_regular_hours_per_day
    is_night_shift_day <- is_night_shift(out_time)

    day_salary <- hourly_rate * regular_hours + calculate_overtime_salary(total_hours_worked, hourly_rate, is_night_shift_day, day_type)
  }

  return(list(day_salary = day_salary, overtime_hours = overtime_hours))
}

# Function to generate weekly payroll
generate_weekly_payroll <- function() {
  total_weekly_salary <- 0
  hourly_rate <- calculate_hourly_rate(daily_rate, max_regular_hours_per_day)

  employee_name <- readline("\nEnter employee name: ")

  for (day in 1:7) {
    prompt_in <- paste("Enter IN time for day", day, "(in military time format): ", sep=" ")
    in_time <- as.numeric(readline(prompt_in))

    prompt_out <- paste("Enter OUT time for day", day, "(in military time format): ", sep=" ")
    out_time <- as.numeric(readline(prompt_out))

    prompt_day_type <- paste("Enter day type for day", day, "(normal/rest/holiday): ", sep=" ")
    day_type <- tolower(readline(prompt_day_type))

    result <- calculate_daily_salary(in_time, out_time, hourly_rate, day_type)
    day_salary <- result$day_salary
    overtime_hours <- result$overtime_hours

    cat("\nEmployee Name:", employee_name, "\n")
    cat("Overtime hours (Night Shift Overtime):", overtime_hours, "(", ifelse(is_night_shift(out_time), "0", overtime_hours), ")\n")
    cat("Salary for day", day, ":", day_salary, "\n")

    total_weekly_salary <- total_weekly_salary + day_salary
  }

  cat("\nTotal weekly salary for", employee_name, ":", total_weekly_salary, "\n")
}

# Modify default configuration
modify_default_configuration <- function() {
  while (TRUE) {
    cat("Current Default Configuration:\n")
    cat("1. Daily Rate:", daily_rate, "\n")
    cat("2. Max Regular Hours per Day:", max_regular_hours_per_day, "\n")
    cat("3. Work Days per Week:", work_days_per_week, "\n")
    cat("4. Rest Days per Week:", rest_days_per_week, "\n")
    
    choice <- as.numeric(readline("Enter the number to modify (0 to exit): "))
    
    if (choice == 0) {
      break
    } else if (choice == 1) {
      daily_rate <- as.numeric(readline("Enter new daily rate: "))
    } else if (choice == 2) {
      new_max_regular_hours <- as.numeric(readline("Enter new max regular hours per day: "))
      if (new_max_regular_hours > 0 && new_max_regular_hours <= 24) {
        max_regular_hours_per_day <- new_max_regular_hours
      } else {
        cat("Invalid input.\n")
      }
    } else if (choice == 3) {
      new_work_days_per_week <- as.numeric(readline("Enter new work days per week: "))
      if (new_work_days_per_week > 0 && new_work_days_per_week <= 7) {
        work_days_per_week <- new_work_days_per_week
      } else {
        cat("Invalid input.\n")
      }
    } else if (choice == 4) {
      new_rest_days_per_week <- as.numeric(readline("Enter new rest days per week: "))
      if (new_rest_days_per_week >= 0) {
        rest_days_per_week <- new_rest_days_per_week
      } else {
        cat("Invalid input. \n")
      }
    }else {
      cat("Invalid choice. Please enter a valid option.\n")
    }
  }
}


# Menu function
while (TRUE) {
  cat("Menu:\n")
  cat("1. Generate Weekly Payroll\n")
  cat("2. Modify Default Configuration\n")
  cat("3. Exit\n")
  
  choice <- as.numeric(readline("Enter your choice: "))
  
  if (choice == 1) {
    generate_weekly_payroll()
  } else if (choice == 2) {
    modify_default_configuration()
  } else if (choice == 3) {
    cat("Program will now be terminated!\n")
    break
  } else {
    cat("Invalid choice. Please enter a valid option.\n")
  }
}
