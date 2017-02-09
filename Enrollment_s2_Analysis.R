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
index = students$Class == 2020 & !is.na(students$X9th.Sem.1.GPA)
students$PriorSemGPA[index] <- students$X9th.Sem.1.GPA[index]
index = students$Class == 2019 & !is.na(students$X10th.Sem.1.GPA)
students$PriorSemGPA[index] <- students$X10th.Sem.1.GPA[index]
index = students$Class == 2018 & !is.na(students$X11th.Sem.1.GPA)
students$PriorSemGPA[index] <- students$X11th.Sem.1.GPA[index]
index = students$Class == 2017 & !is.na(students$X12th.Sem.1.GPA)
students$PriorSemGPA[index] <- students$X12th.Sem.1.GPA[index]

# categorize ACT score
students$X8th.Grade.Diagnostic.ACT.Math= strtoi(students$X8th.Grade.Diagnostic.ACT.Math)
students$X9th.Grade.Diagnostic.ACT.Math= strtoi(students$X9th.Grade.Diagnostic.ACT.Math)

students$lowACT = NA
index = students$Class == 2020 & students$X8th.Grade.Diagnostic.ACT.Math < 17 & !is.na(students$X8th.Grade.Diagnostic.ACT.Math)
students$lowACT[index] = students$X8th.Grade.Diagnostic.ACT.Math[index]
index = students$Class == 2019 & students$X9th.Grade.Diagnostic.ACT.Math < 18 & !is.na(students$X9th.Grade.Diagnostic.ACT.Math)
students$lowACT[index] = students$X9th.Grade.Diagnostic.ACT.Math[index]

  
# keep only relevant variables in student file
variables = names(students) %in% c("Contact.ID", "Contact..Site", "Class", "PriorSemGPA", "lowACT")
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
enrollment = merge(students, tutoring, by="Contact.ID")
enrollment = enrollment[!is.na(enrollment$PriorSemGPA),]

# estimating if students meet tutoring expectations
enrollment$Tutoring3sessions = 0
enrollment$Tutoring3sessions[enrollment$Hours >=3] = 1

enrollment$Tutoring2sessions = 0
enrollment$Tutoring2sessions[enrollment$Hours >=2] = 1

enrollment$Tutoring1sessions = 0
enrollment$Tutoring1sessions[enrollment$Hours >=0.5] = 1

enrollment$freshman= NA
enrollment$freshman[enrollment$Class == 2020]= 1
enrollment$freshman[enrollment$Class < 2020 & enrollment$Class>=2017] = 0
enrollment$Count = 1
enrollment$GPABelow3 = NA
enrollment$GPABelow3[enrollment$PriorSemGPA < 3.0]= 1
enrollment$GPABelow3[enrollment$PriorSemGPA >= 3.0]= 0
enrollment$category = ''
enrollment$category[enrollment$freshman == 1 & enrollment$GPABelow3 ==1] = "9th grader, below 3.0"
enrollment$category[enrollment$freshman == 1 & enrollment$GPABelow3 ==0] = "9th grader, above 3.0"
enrollment$category[enrollment$freshman == 0 & enrollment$GPABelow3 ==1] = "10-12th grader, below 3.0"
enrollment$category[enrollment$freshman == 0 & enrollment$GPABelow3 ==0] = "10-12th grader, above 3.0"


# results table summarizing % students meeting enrollment expectations by GPA, Class, & site
results_mean = summaryBy(Contact..Site + Class + Tutoring3sessions + Tutoring2sessions + Tutoring1sessions ~ category , FUN = c(mean), data = enrollment)
results_sum = summaryBy(Count ~ category, FUN = c(sum), data = enrollment)

