# Jason Scott
# Dec 2016

#install.packages("doBy")
library(doBy)

# import data files from CEO folder in Salesfore
setwd("~/Desktop/CT/dosage/")
students = read.csv("students.csv")
attendance = read.csv("enrollments.csv")

# identify prior term GPA in student file
students$PriorSemGPA = NA
index = students$Class == 2020 & !is.na(students$Contact..Middle.School.GPA)
students$PriorSemGPA[index] <- students$Contact..Middle.School.GPA[index]
index = students$Class == 2019 & !is.na(students$X9th.Sem.2.GPA)
students$PriorSemGPA[index] <- students$X9th.Sem.2.GPA[index]
index = students$Class == 2018 & !is.na(students$X10th.Sem.2.GPA)
students$PriorSemGPA[index] <- students$X10th.Sem.2.GPA[index]
index = students$Class == 2017 & !is.na(students$X11th.Sem.2.GPA)
students$PriorSemGPA[index] <- students$X11th.Sem.2.GPA[index]

# keep only relevant variables in student file
variables = names(students) %in% c("Contact.ID", "Contact..Site", "Class", "PriorSemGPA")
students = students[variables]

# keep only active tutoring enrollments that have Duration from attendance file:
tutoring = attendance[ which(attendance$Status == 'Active' & attendance$Type == 'Tutoring' & attendance$Duration != "#Error!"),]

# keep only Duration & student ID variables from attendance file
variables = names(attendance) %in% c("Student..Contact.ID", "Duration", "Type") 
tutoring = tutoring[variables]

# transform Duration variable to numeric in attendance file
tutoring$Tutoring.MinsPerWeek = as.numeric(levels(tutoring$Duration))[tutoring$Duration]

# summarize enrollment data by student (collapse data using "doBy" library)
tutoring = summaryBy(Tutoring.MinsPerWeek ~ Student..Contact.ID, FUN = c(sum), data = tutoring)
names(tutoring) = c("Contact.ID", "TutoringMinutes.PerWeek")
tutoring$Hours = tutoring$TutoringMinutes.PerWeek/60

# merge data files
dosage = merge(students, tutoring, by="Contact.ID")
dosage = dosage[!is.na(dosage$PriorSemGPA),]

# estimating if students meet tutoring expectations
dosage$Meets.Tutoring.Expectation = 0
index = dosage$PriorSemGPA < 2.5 & dosage$Hours >=3 # students with GPAs below 2.5 need at least 3 hours
dosage$Meets.Tutoring.Expectation[index] = 1

index = dosage$Class == 2020 & dosage$PriorSemGPA >= 2.5 & dosage$PriorSemGPA < 3.0 & dosage$Hours >= 3 # 9th graders with GPAs between 2.49 and & 3.0 need 3 hrs
dosage$Meets.Tutoring.Expectation[index] = 1

# upperclassmen with GPAs between 2.49 and 3.0 need at least 2 hrs of tutoring
index = dosage$Class != 2020 & dosage$PriorSemGPA >= 2.5 & dosage$PriorSemGPA < 3.0 & dosage$Hours >= 3
dosage$Meets.Tutoring.Expectation[index] = 1

index = dosage$Class == 2020 & dosage$PriorSemGPA >=3 & dosage$Hours >= 2 # 9th graders with GPAs above 3.0 need 2+ hrs
dosage$Meets.Tutoring.Expectation[index] = 1

# upperclassmen with 3.0+ GPAs need at least 1 hr of tutoring
index = dosage$Class != 2020 & dosage$PriorSemGPA >=3 & dosage$Hours >= 1
dosage$Meets.Tutoring.Expectation[index] = 1

# results table summarizing % students meeting enrollment expectations by GPA, Class, & site
results = summaryBy(Meets.Tutoring.Expectation ~ Contact..Site + Class, FUN = c(mean), data = dosage)

# average enrollment hours by Class & Site
enrollment.all = attendance[attendance$Status == 'Active' & attendance$Duration != '' & attendance$Duration != '#Error!',]
enrollment.all$Mins = NA
enrollment.all$Mins = as.numeric(levels(enrollment.all$Duration))[enrollment.all$Duration]
enrollment.all$Hours = enrollment.all$Mins/60

# This code is not yet working
Hours.Enrolled = summaryBy(Hours ~ Contact..Site + Class, FUN = c(mean), data = enrollment.all)


